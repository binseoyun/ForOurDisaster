import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import '../services/location_service.dart';


//친구 위치를 뜨게 수정
//상단에서 친구 보기 버튼을 누르면 대피소 마커가 사라지고, 친구의 위치가 뜨게 설정


class ShelterMapScreen extends StatefulWidget {
  const ShelterMapScreen({super.key});

  @override
  State<ShelterMapScreen> createState() => _ShelterMapScreenState();
}

class _ShelterMapScreenState extends State<ShelterMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  String? _errorMessage;
  bool _isLoading = true;

  Set<Marker> _friendMarkers = {};
  Set<Marker> _shelterMarkers = {}; //대피소 마커
  bool _showFriends = false; // 친구 위치 표시 여부
  StreamSubscription<QuerySnapshot>? _friendLocationsSubscription;
  final LocationService _locationService = LocationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //드롭다운 대피소 유형 목록과 선택값
  final Map<String, String> shelterTypes = {
    '반경 5km 내 전체 대피소': '',
    '한파 쉼터': '1',
    '무더위 쉼터': '2',
    '지진 옥외 대피장소': '3',
    '지진 해일 긴급 대피장소': '4',
  };
  String _selectedShelterCode = ''; //기본:전체

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
    _setupFriendLocations();
  }

  @override
  void dispose() {
    _friendLocationsSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // 친구 위치 업데이트 구독 설정
  void _setupFriendLocations() {
    _friendLocationsSubscription = _firestore
        .collection('user_locations')
        .where('timestamp', isGreaterThan: DateTime.now().subtract(const Duration(hours: 1)))
        .snapshots()
        .listen((snapshot) {
          _updateFriendMarkers(snapshot.docs);
        });
  }

  // 친구 마커 업데이트
  void _updateFriendMarkers(List<QueryDocumentSnapshot> docs) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final friendMarkers = <Marker>{};
    
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final userId = data['userId'] as String?;
      final position = data['position'] as GeoPoint?;
      
      // 현재 사용자 제외
      if (userId == null || position == null || userId == currentUser.uid) continue;
      
      // 사용자 정보 가져오기
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName = userDoc.data()?['name'] as String? ?? '알 수 없음';
      final updatedAt = data['timestamp'] as Timestamp?;
      
      friendMarkers.add(Marker(
        markerId: MarkerId('friend_$userId'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(
          title: userName,
          snippet: updatedAt != null ? '업데이트: ${updatedAt.toDate().toLocal()}' : null,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      ));
    }

    if (mounted) {
      setState(() {
        _friendMarkers = friendMarkers;
      });
    }
  }

  //지도에 대피소 api에서 받아온 정보를 띄우는 흐름
  //1.현재 위치를 가져옴(_fetchCurrentLoation()안에서 Geolocator.getCurrentPosition()호출)
  //2.대피소 API 호출(fetchShelterMarkers(currentPostion) 호출해서 API에 요청보냄)
  //3.API 응답 받아서 마커 생성 => 위도,경도 있는 항목들만 Markers로 변환
  //4.지도에 표시할 마커 set해서 저장(_shelterMarkers= ..)
  //5.build()에서 지도에 마커 표시(GoogleMap(markers:allMarkers)안에 포함됨)

  // 현재 위치 기반 대피소 데이터 가져오기
  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = '위치 서비스가 비활성화되어 있습니다.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = '위치 권한이 거부되었습니다.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = '위치 권한이 영구적으로 거부되었습니다.';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      final shelterMarkers = await fetchShelterMarkers(latLng, _selectedShelterCode);

      if (mounted) {
        setState(() {
          _currentPosition = latLng;
          _shelterMarkers = shelterMarkers.toSet();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '위치를 불러오는 중 오류 발생: $e';
        _currentPosition = const LatLng(37.5665, 126.9780);
        _isLoading = false;
      });
    }
  }

  //공공데이터 API 호출 함수
  Future<List<Marker>> fetchShelterMarkers(
    LatLng position,
    String shelterCode,
  ) async {

    final serviceKey = dotenv.env['PUBLIC_SHELTER_API_KEY'] ?? '';

    //const serviceKey = 'C6U74L503B938FO4';
    

    const delta = 0.05; //10km반경 이내의 대피소 위치 지정

    final startLat = (position.latitude - delta).toStringAsFixed(6); //시작위도
    final endLat = (position.latitude + delta).toStringAsFixed(6); //종료위도
    final startLot = (position.longitude - delta).toStringAsFixed(6); //시작경도
    final endLot = (position.longitude + delta).toStringAsFixed(6); //종료 경도

    final queryParams = {
      'serviceKey': serviceKey,
      'returnType': 'json',
      'numOfRows': '100',
      'pageNo': '1',
      'startLat': startLat,
      'endLat': endLat,
      'startLot': startLot,
      'endLot': endLot,
    };
    if (shelterCode.isNotEmpty) {
      queryParams['shlt_se_cd'] = shelterCode;
    }
    //안전한 url 생성
    final url = Uri.https(
      'www.safetydata.go.kr',
      '/V2/api/DSSP-IF-10941',
      queryParams,
    );

    //API 요청 URL 확인
    print('대피소 API 요청 URL: $url');

    final response = await http.get(url);

    //API 응답 상태 및 데이터 확인
    print('대피소 API 응답 상태코드: ${response.statusCode}');
    print('대피소 API 응답 본문: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['body'] as List<dynamic>?;

      if (items == null) {
        print('body가 null입니다!!!');
        return [];
      }

      print('대피소 개수: ${items.length}');

      //각 대피소의 이름 확인
      for (var item in items) {
        print(
          '대피소: ${item['REARE_NM']} (${item['LAT']}, ${item['LOT']} , ${item['SHLT_SE_CD']})',
        );
      }

      //파싱한 대피소 개수 확인
      print('파싱된 대피소 개수: ${items.length}');

      //여러개 포함되어 있는 경우를 대비해서 contains로 변경
      final filteredItems = items.where((item) {
        final code = item['SHLT_SE_CD']?.toString() ?? '';
        if (shelterCode.isEmpty) return true;
        return code.split(',').map((s) => s.trim()).contains(shelterCode);
      }).toList();

      return filteredItems
          .map<Marker?>((item) {
            final lat = double.tryParse(item['LAT']?.toString() ?? '');
            final lon = double.tryParse(item['LOT']?.toString() ?? '');
            final name = item['REARE_NM'] ?? '이름 없음';
            final address = item['RONA_DADDR'] ?? '주소 없음';
            //final typeCode = item['SHLT_SE_CD'] ?? '';

            //대피소이름은 잘 출력되고 있는 상태

            if (lat == null || lon == null) return null;

            //대피소 유형별 색상 지정
            double markerColor;

            // 전체 대피소 선택 시 모든 대피소를 같은 색(초록색)으로 표시
            if (shelterCode.isEmpty) {
              markerColor = BitmapDescriptor.hueGreen; // 전체 대피소는 초록색
            } else {
              // 특정 유형 선택 시 해당 색상으로 표시
              switch (shelterCode) {
                case '1':
                  markerColor = BitmapDescriptor.hueAzure; // 한파쉼터 - 하늘색
                  break;
                case '2':
                  markerColor = BitmapDescriptor.hueOrange; // 무더위쉼터 - 주황색
                  break;
                case '3':
                  markerColor = BitmapDescriptor.hueYellow; // 지진옥외대피소 - 노란색
                  break;
                case '4':
                  markerColor = BitmapDescriptor.hueViolet; // 지진해일긴급대피소 - 보라색
                  break;
                default:
                  markerColor = BitmapDescriptor.hueGreen; // 기본 색
              }
            }

            return Marker(
              markerId: MarkerId(item['MNG_SN'] ?? UniqueKey().toString()),
              position: LatLng(lat, lon),
              infoWindow: InfoWindow(title: name, snippet: address),
              icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
            );
          })
          .whereType<Marker>()
          .toList();
    } else {
      print('대피소 API 오류: ${response.statusCode}');
      return [];
    }
  }

  //int _selectedIndex = 0;
  /*
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: 탭 이동 처리
  }*/

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentPosition == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 현재 표시할 마커들 선택 (친구 또는 대피소)
    final currentMarkers = _showFriends ? _friendMarkers : _shelterMarkers;

    // 내 위치 마커 생성
    final myLocationMarker = Marker(
      markerId: const MarkerId('my_location'),
      position: _currentPosition!,
      infoWindow: const InfoWindow(title: '내 위치'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    
    // 선택된 마커와 내 위치 마커 합치기
    final allMarkers = Set<Marker>.from(currentMarkers)..add(myLocationMarker);

    //드롭바 추가하기 위해 잠깐 주석처리

    return Scaffold(
      appBar: AppBar(
        title: const Text('대피소 지도', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 상단 컨트롤 바
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // 친구/대피소 토글 버튼
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showFriends = !_showFriends;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showFriends ? Colors.blue[100] : null,
                  ),
                  child: Text(_showFriends ? '대피소 보기' : '친구 위치 보기'),
                ),
                const SizedBox(width: 10),
                // 대피소 유형 드롭다운 (대피소 모드일 때만 표시)
                if (!_showFriends) Expanded(
                  child: DropdownButton<String>(
                    value: _selectedShelterCode,
                    isExpanded: true,
                    items: shelterTypes.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      setState(() {
                        _selectedShelterCode = value ?? '';
                        _isLoading = true;
                      });

                      // 현재 위치가 있을 때만 대피소 마커 업데이트
                      if (_currentPosition != null) {
                        final markers = await fetchShelterMarkers(
                          _currentPosition!,
                          _selectedShelterCode,
                        );
                        if (mounted) {
                          setState(() {
                            _shelterMarkers = markers.toSet();
                            _isLoading = false;
                          });
                        }
                      } else {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // ✅ 지도
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14,
              ),
              markers: allMarkers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
            ),
          ),
        ],
      ),
    );
  }
}
