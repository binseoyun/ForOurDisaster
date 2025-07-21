import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
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
    final allMarkers = Set<Marker>.from(_friendMarkers)..add(myLocationMarker);

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
