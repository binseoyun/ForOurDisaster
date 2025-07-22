import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import '../widgets/weather_section.dart';
import '../widgets/quiz_section.dart';
import '../widgets/disaster_alert_section.dart';
import '../models/disaster_alert.dart';
import '../services/disaster_service.dart';

import 'alarm_screen.dart';
import 'chatbot_screen.dart';

import 'package:firebase_messaging/firebase_messaging.dart';


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
  final DisasterService _disasterService = DisasterService();

  //재난 문자 멤버 변수 추가
  List<DisasterAlert> latestAlerts = [];

  String cityName = 'Unknown';
  String? _administrativeArea; // 시도 (e.g. 서울특별시)
  String? _locality; // 시군구 (e.g. 강남구)

  String _formatTime(String? rawDateTime) {
    if (rawDateTime == null) return '';
    try {
      final dt = DateTime.parse(
        rawDateTime.replaceAll('/', '-').replaceAll(' ', 'T'),
      );
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      print('Error parsing time: $rawDateTime - $e');
      return '';
    }
  }

  //사용자가 로그인해서 홈 화면에 들어오면 바로 FCM 토큰을 저장
  //firebase functions을 통해 상대방에게 push 알람을 보낼 때 fcmToken을 통해서 상대를 확인
  //push_function/index.js의 sendLocationRequest 함수가 firebase store의 users에서 email==targetEmail 조건으로 FCM 토큰을 가져와야 알림을 보냄
  @override
  void initState() {
    super.initState();
    //fcm 토큰 관련 
    saveFcmTokenToFirestore(); //홈화면 오면 토큰을 저장하게 함수 호출
    _fetchWeatherData(); // This will now trigger _fetchDisasterAlerts internally

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
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      try {
        // Get city name from coordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _administrativeArea = _getNonEmptyString(
            place.administrativeArea,
          ); //시도
          _locality = _getNonEmptyString(place.locality); //시군구

          print('Administrative Area: $_administrativeArea');
          print('Locality: $_locality');

          cityName = (_administrativeArea?.isNotEmpty ?? false)
              ? '$_administrativeArea ${(_locality?.isNotEmpty ?? false) ? _locality! : ''}'
                    .trim()
              : ((_locality?.isNotEmpty ?? false) ? _locality! : 'Unknown');
        } else {
          print('placemarks 비어있음. 위치 이름을 찾지 못함.');
          cityName = 'Unknown';
        }
      } catch (e) {
        print('Error getting city name from coordinates: $e');
        cityName = 'Location Unavailable'; // Fallback if geocoding fails
      }

      final weatherJson = await _weatherService.fetchWeather(
        position.latitude,
        position.longitude,
      );

      // Add the resolved city name to the json before parsing
      weatherJson['name'] = cityName;

      setState(() {
        weatherData = WeatherData.fromJson(weatherJson);
        isLoading = false;
      });

      // 현재 날짜를 YYYYMMDD 형식으로 가져오기
      final String currentDate = DateFormat('yyyyMMdd').format(DateTime.now());

      // Call disaster alerts fetch AFTER weather data and city name are resolved
      _fetchDisasterAlerts(currentDate);
    } catch (e, stackTrace) {
      print('Error fetching weather data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  //재난 문자 API 불러오기
  Future<void> _fetchDisasterAlerts(String? currentDate) async {
    try {
      String regionNameForDisaster;

      // 지역명 결정
      if (_locality != null &&
          _locality!.isNotEmpty &&
          _locality != 'Unknown') {
        // 시군구가 유효하면 '시도 시군구' 형태로 조합
        regionNameForDisaster = '${_administrativeArea ?? ''} $_locality'
            .trim();
      } else if (_administrativeArea != null &&
          _administrativeArea!.isNotEmpty &&
          _administrativeArea != 'Unknown') {
        // 시도만 유효하면 시도만 사용
        regionNameForDisaster = _administrativeArea!;
      } else {
        // 둘 다 유효하지 않으면 '서울특별시'를 기본으로 사용
        regionNameForDisaster = '서울특별시';
        print('지역명이 Unknown이거나 비어있어 기본 지역인 서울특별시로 설정합니다');
      }

      // currentDate가 null이면 현재 날짜로 폴백
      final String finalCrtDt =
          currentDate ?? DateFormat('yyyyMMdd').format(DateTime.now());

      print(
        'Fetching disaster alerts for region: $regionNameForDisaster with date: $finalCrtDt',
      );
      final rawAlerts = await _disasterService.fetchLatestAlerts(
        region: regionNameForDisaster,
        crtDt: finalCrtDt,
      );
      print('Received ${rawAlerts.length} raw alerts from API.');

      final alerts = rawAlerts
          .map((json) => DisasterAlert.fromJson(json))
          .toList();
      print('Parsed ${alerts.length} DisasterAlert objects.');

      setState(() {
        latestAlerts = alerts;
      });
    } catch (e) {
      print('Error fetching disaster alerts: $e');
      setState(() {
        errorMessage = '재난 문자 불러오기 실패: ${e.toString()}';
      });
    }
  }

  String? _getNonEmptyString(String? value) {
    return (value != null && value.isNotEmpty && value != 'Unknown')
        ? value
        : null;
  }

//FCM 토큰 관련

Future<void> saveFcmTokenToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userDoc.set({
      'email': user.email,
      'fcmToken': fcmToken,
    }, SetOptions(merge: true)); //기존 데이터 데이터 덮어쓰지 않세 mrege사용
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
            padding: const EdgeInsets.only(
              top: 20.0,
              right: 10.0,
            ), // 상단 및 우측 여백 추가
            child: IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                String regionToPass;

                if (_administrativeArea != null &&
                    _administrativeArea!.isNotEmpty &&
                    _administrativeArea != 'Unknown') {
                  // _locality가 유효하면 '시도 시군구' 형태로, 아니면 '시도'만 사용
                  if (_locality != null &&
                      _locality!.isNotEmpty &&
                      _locality != 'Unknown') {
                    regionToPass = '${_administrativeArea!} ${_locality!}'
                        .trim();
                  } else {
                    regionToPass = _administrativeArea!; // 시군구가 없으면 시도만 보냄
                  }
                } else {
                  // _administrativeArea가 유효하지 않으면 '서울특별시'를 기본값으로 사용
                  regionToPass = '서울특별시';
                  print(
                    'DisasterAlertListScreen으로 전달할 위치 정보가 아직 없어서 기본 지역인 서울특별시로 설정합니다.',
                  );
                }

                print('DisasterAlertListScreen으로 전달하는 지역: $regionToPass');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AlarmScreen(initialRegion: regionToPass),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 날씨 정보
                WeatherSection(
                  weatherData: weatherData,
                  errorMessage: errorMessage,
                ),

                const SizedBox(height: 20),

                DisasterAlertSection(
                  alerts: latestAlerts
                      .map(
                        (alert) => {
                          'title': alert.emrgStepNm,
                          'message': alert.msgCn,
                          'time': alert.formattedTime, //"12:27 PM 형식"
                        },
                      )
                      .toList(),
                  region:
                      _locality != null &&
                          _locality!.isNotEmpty &&
                          _locality != 'Unknown'
                      ? '${_administrativeArea ?? ''} $_locality'.trim()
                      : _administrativeArea ?? '서울특별시',
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
          //챗봇 아이콘
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatbotScreen(),
                  ),
                );
              },
              child: const Icon(
                Icons.chat_bubble,
                color: Color.fromARGB(159, 28, 92, 31),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

