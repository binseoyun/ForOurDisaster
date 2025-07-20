import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import '../widgets/weather_section.dart';
import '../widgets/quiz_section.dart';
import '../widgets/disaster_alert_section.dart';
import 'disaster_alert_list_screen.dart';

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
  final WeatherService _weatherService = WeatherService();

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

  Future<void> _fetchWeatherData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      String cityName = 'Unknown Location';
      try {
        // Get city name from coordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          // Use a helper to ensure non-empty string, falling back to 'Unknown'
          cityName = _getNonEmptyString(place.locality) ??
                     _getNonEmptyString(place.subLocality) ??
                     _getNonEmptyString(place.administrativeArea) ??
                     'Unknown';
        }
      } catch (e) {
        print('Error getting city name from coordinates: $e');
        cityName = 'Location Unavailable'; // Fallback if geocoding fails
      }

      final weatherJson =
          await _weatherService.fetchWeather(position.latitude, position.longitude);
      
      // Add the resolved city name to the json before parsing
      weatherJson['name'] = cityName;

      setState(() {
        weatherData = WeatherData.fromJson(weatherJson);
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error fetching weather data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // Helper function to return a string if it's not null or empty, otherwise null
  String? _getNonEmptyString(String? value) {
    return (value != null && value.isNotEmpty) ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        toolbarHeight: 80, // AppBar 높이 조절
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0), // 상단 여백 추가
          child: const Text(
            'ForOurDisaster',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 10.0), // 상단 및 우측 여백 추가
            child: IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DisasterAlertListScreen(),
                  ),
                );
              },
            ),
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
            WeatherSection(weatherData: weatherData, errorMessage: errorMessage),

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
    );
  }
}
