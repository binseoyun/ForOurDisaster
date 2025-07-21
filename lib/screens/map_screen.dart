import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http; //공공 데이터 API 호출 함수 만들기 위해 추가한 2개 import
import 'dart:convert';

//현재 내 위치 기반으로는 뜨게 가능
//친구 실시간 위치 띄우기 구현 - 확인 필요
//1.대피소 위치 api를 받아서 위도와 경도를 받아서 firestore에 저장 후 가져오기
//2.geolocator 패키지의 Geolocator.distanceBetween() 매서드를 통해 현재 위치와 거리 계산
//3.가까운 대피소만 필터링
//4.지도에 마커로 표시





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
  Set<Marker> _ShelterMarkers={}; //대피소 마커

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  //지도에 대피소 api에서 받아온 정보를 띄우는 흐름
  //1.현재 위치를 가져옴(_fetchCurrentLoation()안에서 Geolocator.getCurrentPosition()호출)
  //2.대피소 API 호출(fetchShelterMarkers(currentPostion) 호출해서 API에 요청보냄)
  //3.API 응답 받아서 마커 생성 => 위도,경도 있는 항목들만 Markers로 변환
  //4.지도에 표시할 마커 set해서 저장(_shelterMarkers= ..)
  //5.build()에서 지도에 마커 표시(GoogleMap(markers:allMarkers)안에 포함됨)

  //현재 위치 기반 대피소 데이터 가져오기

  //공공데이터 API 호출 함수
  Future<List<Marker>> fetchShelterMarkers(LatLng position) async{
     const serviceKey='C6U74L503B938FO4';
     const delta=0.05; //5km반경 이내의 대피소 위치 지정

     final startLat=(position.latitude - delta).toStringAsFixed(6); //시작위도
     final endLat=(position.latitude+delta).toStringAsFixed(6); //종료위도
     final startLot=(position.longitude-delta).toStringAsFixed(6); //시작경도
     final endLot=(position.longitude+delta).toStringAsFixed(6); //종료 경도

     final url=Uri.parse(
      'https://apis.data.go.kr/V2/api/DSSP-IF-10941'
      '?serviceKey=$serviceKey'
      '&returnType=json'
      '&numOfRows=100'
      '&pageNo=1'
      '&startLat=$startLat'
      '&endLat=$endLat'
      '&startLot=$startLot'
      '&endLot=$endLot'
      '&shlt_se_cd=3', // 지진 옥외 대피장소 (필요시 변경)
     );

      final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['response']['body']['items'] as List<dynamic>?;

      if (items == null) return [];

      return items.map<Marker?>((item) {
        final lat = double.tryParse(item['LAT'] ?? '');
        final lon = double.tryParse(item['LOT'] ?? '');
        final name = item['REARE_NM'] ?? '이름 없음';
        final address = item['RONA_DADDR'] ?? '주소 없음';

        if (lat == null || lon == null) return null;

        return Marker(
          markerId: MarkerId(item['MNG_SN'] ?? UniqueKey().toString()),
          position: LatLng(lat, lon),
          infoWindow: InfoWindow(title: name, snippet: address), 
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );
      }).whereType<Marker>().toList();
    } else {
      print('대피소 API 오류: ${response.statusCode}');
      return [];
    }


  }





  Future<void> _fetchCurrentLocation() async {
    try {
      // 위치 서비스가 활성화되어 있는지 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = '위치 서비스가 비활성화되어 있습니다. 설정에서 위치 서비스를 활성화해주세요.';
          _isLoading = false;
        });
        return;
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = '위치 권한이 거부되었습니다. 설정에서 위치 권한을 허용해주세요.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = '위치 권한이 영구적으로 거부되었습니다. 설정에서 위치 권한을 허용해주세요.';
          _isLoading = false;
        });
        return;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      setState(() {
        //지금 position에서 경도와 위도는 잘 호출한 상태
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });


    } catch (e) {
      print('위치 불러오기 오류: $e');
      setState(() {
        _errorMessage = '위치를 불러오는 중 오류가 발생했습니다: ${e.toString()}';
        _isLoading = false;
        // 기본 위치 설정 (서울)
        _currentPosition = const LatLng(37.5665, 126.9780);
      });
    }
  }




  Future<void> _loadFriendLocations() async {
  final snapshot = await FirebaseFirestore.instance.collection('users').get();

  final markers = snapshot.docs.map((doc) {
    final data = doc.data();
    final location = data['location'];
    if (location is GeoPoint) {
      final name = data['name'] ?? '익명';
      final updatedAt = data['locationUpdatedAt'];

      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(
          title: name,
          snippet: updatedAt != null
              ? '업데이트: ${updatedAt.toDate().toLocal()}'
              : null,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }
    return null;
  }).whereType<Marker>().toSet();

  setState(() {
    _friendMarkers = markers;
  });
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 내 위치 마커 생성
    final myLocationMarker = Marker(
      markerId: const MarkerId('my_location'),
      position: _currentPosition!,
      infoWindow: const InfoWindow(title: '내 위치'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

     // 친구 마커와 내 위치 마커 합치기
    final allMarkers = Set<Marker>.from(_friendMarkers)
    ..add(myLocationMarker)
    ..addAll(_ShelterMarkers); //대피소 마커 추가

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('대피소 지도', style: TextStyle(color: Colors.black)),
            Text('대피소 위치를 확인하세요',
                style: TextStyle(color: Colors.grey, fontSize: 12))
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

        body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
          _loadFriendLocations();
        },
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 15,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: allMarkers,
            ),
    );
  }
}
