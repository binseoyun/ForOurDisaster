import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather_data.dart';
import '../widgets/weather_section.dart';
import '../widgets/quiz_section.dart';
import '../widgets/disaster_alert_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherData? weatherData;
  Timer? _timer;
  bool isLoading = true;
  String? errorMessage;
  int _selectedIndex = 0;

  // OpenWeatherMap API 키 - 실제 키로 교체해야 합니다
  static const String API_KEY = 'YOUR_API_KEY_HERE';
  static const String BASE_URL =
      'https://api.openweathermap.org/data/3.0/onecall';

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
    // 매 시간마다 날씨 데이터 업데이트
    _timer = Timer.periodic(Duration(hours: 1), (timer) {
      _fetchWeatherData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchWeatherData() async {
    //실제 API 호출 로직(http:get)
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // 위치 권한 확인 및 요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 위치 이름 가져오기 (Reverse Geocoding)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String cityName = 'Unknown Location';
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        cityName =
            place.locality ?? place.administrativeArea ?? 'Unknown Location';
      }

      // OpenWeatherMap API 호출
      final url = Uri.parse(
        '$BASE_URL?lat=${position.latitude}&lon=${position.longitude}&appid=$API_KEY&units=metric',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // 위치 이름을 API 응답에 추가
        jsonData['city_name'] = cityName;

        setState(() {
          weatherData = WeatherData.fromJson(jsonData);
          isLoading = false;
        });
      } else {
        throw Exception('날씨 데이터를 불러오는데 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      // 에러 발생 시 더미 데이터 사용
      _loadDummyData();
    }
  }

  //예시 데이터 - 교체 필요 TODO API
  void _loadDummyData() {
    setState(() {
      weatherData = WeatherData(
        description: 'Thunderstorm',
        iconCode: '11d',
        cloudiness: 75,
        locationName: 'Daejeon',
        tempCurrent: 23.5,
        tempHigh: 28.0,
        tempLow: 18.0,
        precipitationProbablity: 0.65,
        precipitationType: 'Rain',
        uvi: 5.2,
        humidity: 80,
        windSpeed: 3.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text(
          'ForOurDisaster',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 날씨 정보
            WeatherSection(weatherData: weatherData),

            const SizedBox(height: 20),

            DisasterAlertSection(
              alerts: [
                {
                  'title': '긴급재난문자',
                  'message': '강풍으로 인한 시설물 피해가 예상됩니다. 외출 시 주의하시기 바랍니다.',
                  'time': '9:36 AM',
                },
                {
                  'title': '긴급재난문자',
                  'message': '집중호우 경보가 발령되었습니다. 저지대 및 하천 근처는 피해주세요.',
                  'time': '8:15 AM',
                },
                {
                  'title': '긴급재난문자',
                  'message': '지진 발생으로 인한 여진이 예상됩니다. 안전한 곳으로 대피하세요.',
                  'time': '7:42 AM',
                },
              ],
            ),

            const SizedBox(height: 24),

            // 오늘의 상식 퀴즈
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuizSection(),
            ),

            const SizedBox(height: 20), // 하단 padding
          ],
        ),
      ),
      //하단 네이게이션 바
      bottomNavigationBar: SizedBox(
        height: 75,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFFF9FBFA),
          iconSize: 30,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.location_on), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.warning), label: ''),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
