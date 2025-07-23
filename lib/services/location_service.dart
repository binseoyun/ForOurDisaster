//사용자의 현재 위치(위도, 경도) 및 이를 행정구역(시도, 시군구)으로 변환

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart'; // Add this line

class LocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Location sharing state
  bool _isSharingLocation = false;
  StreamSubscription<Position>? _positionStream;
  
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();
  // 현재 위치 위도, 경도 가져오기
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 비활성화되어 있습니다.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 거부되었습니다. 설정에서 권한을 변경해주세요.');
    }
    
    return await Geolocator.getCurrentPosition();
  }
  
  // 위치 권한 확인 (내부 전용)
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 비활성화되어 있습니다.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 거부되었습니다. 설정에서 권한을 변경해주세요.');
    }
  }

  // 위도, 경도 -> 시도 이름
  static Future<String?> getRegionNameFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        localeIdentifier: "ko_KR",
      );

      if (placemarks.isEmpty) {
        throw Exception('주소를 찾을 수 없습니다.');
      }

      final Placemark place = placemarks.first;
      return place.locality;
    } catch (e) {
      print('Error getting region name: $e');
      return null;
    }
  }
  
  // 위치 공유 시작
  Future<void> startSharingLocation(String userId) async { // Changed targetUserId to userId for clarity
    if (_isSharingLocation) {
      debugPrint('LocationService: Already sharing location.');
      return;
    }
    
    debugPrint('LocationService: Starting location sharing for user $userId');
    await _checkLocationPermission();
    
    _isSharingLocation = true;
    
    // 실시간 위치 업데이트 구독
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10미터마다 업데이트
      ),
    ).listen((Position position) async {
      await _updateLocationInFirestore(position);
    });
    
    // 초기 위치 업데이트
    final position = await getCurrentPosition();
    await _updateLocationInFirestore(position);
  }
  
  // 위치 공유 중지
  Future<void> stopSharingLocation() async {
    debugPrint('LocationService: Stopping location sharing.');
    await _positionStream?.cancel();
    _positionStream = null;
    _isSharingLocation = false;
    
    // Firestore에서 위치 정보 삭제
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        await _firestore.collection('user_locations').doc(userId).delete();
        debugPrint('LocationService: Deleted location data for user $userId from Firestore.');
      } catch (e) {
        debugPrint('LocationService: Error deleting location data for user $userId: $e');
      }
    }
  }
  
  // Firestore에 위치 업데이트
  Future<void> _updateLocationInFirestore(Position position) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      debugPrint('LocationService: User not logged in, cannot update location.');
      return;
    }
    
    try {
      debugPrint('LocationService: Attempting to update location for user $userId');
      await _firestore.collection('user_locations').doc(userId).set({
        'userId': userId,
        'position': GeoPoint(position.latitude, position.longitude),
        'timestamp': FieldValue.serverTimestamp(),
        'lastUpdated': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      debugPrint('LocationService: Location updated successfully for user $userId');
    } catch (e) {
      debugPrint('LocationService: Error updating location for user $userId: $e');
    }
  }
  
  // 특정 사용자의 위치 스트림 가져오기
  Stream<DocumentSnapshot> getUserLocationStream(String userId) {
    return _firestore
        .collection('user_locations')
        .doc(userId)
        .snapshots();
  }
  
  // 모든 공유 중인 위치 스트림 가져오기
  Stream<QuerySnapshot> getAllSharedLocations() {
    return _firestore
        .collection('user_locations')
        .where('timestamp', isGreaterThan: DateTime.now().subtract(const Duration(hours: 1)))
        .snapshots();
  }
  
  // 위치 공유 중인지 확인
  bool get isSharingLocation => _isSharingLocation;
  
  // 리소스 정리
  void dispose() {
    _positionStream?.cancel();
  }
}
