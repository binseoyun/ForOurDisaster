//사용자의 현재 위치(위도, 경도) 및 이를 행정구역(시도, 시군구)으로 변환

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {

  // 현재 위치 위도, 경도 가져오기
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled) {
      throw Exception('위치 서비스가 비활성화되어 있습니다.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  // 위도, 경도 -> 시도 이름
  static Future<String?> getRegionNameFromCoordinates(Position position) async{
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude, 
      position.longitude,
      localeIdentifier: "ko_KR",
    );

    if (placemarks.isNotEmpty) {
      throw Exception('주소를 찾을 수 없습니다.');
    }

      final Placemark place = placemarks.first;
      return place.locality;
  }
}