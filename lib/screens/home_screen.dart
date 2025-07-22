import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../models/firestore_alert.dart';

import 'alarm_screen.dart';
import 'chatbot_screen.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/disaster_alert.dart'; // Added import for DisasterAlert
import '../services/disaster_service.dart'; // Added import for DisasterService

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
  // 재난 문자 멤버 변수 변경 (FirestoreAlert 사용)
  List<FirestoreAlert> latestAlerts = [];

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

      // 현재 위치 정보를 Firestore의 'regions' 필드에 저장
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && (_administrativeArea != null || _locality != null)) {
        final List<String> regionsToSave = [];
        if (_administrativeArea != null && _administrativeArea!.isNotEmpty) {
          regionsToSave.add(_administrativeArea!);
        }
        if (_locality != null && _locality!.isNotEmpty) {
          regionsToSave.add(_locality!);
        }
        // 중복 제거 및 빈 값 제거
        final uniqueRegions = regionsToSave
            .where((r) => r.isNotEmpty)
            .toSet()
            .toList();

        if (uniqueRegions.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'regions': uniqueRegions}, SetOptions(merge: true));
          print('Firestore에 사용자 지역 정보 저장: $uniqueRegions');
        }
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

      // === 재난문자 API에서 받아온 리스트를 Firestore에 자동 저장 ===
      final String currentDate = DateFormat('yyyyMMdd').format(DateTime.now());
      final disasterService = DisasterService();
      final List<Map<String, dynamic>> disasterAlertsFromApi =
          await disasterService.fetchLatestAlerts(
        region: _administrativeArea,
        crtDt: currentDate,
      );
      for (final alert in disasterAlertsFromApi) {
        final disasterAlert = DisasterAlert.fromJson(alert);
        await saveDisasterAlertToFirestore(
          region: disasterAlert.rcptnRgnNm.isNotEmpty
              ? disasterAlert.rcptnRgnNm
              : (_administrativeArea ?? 'Unknown'),
          title: disasterAlert.emrgStepNm.isNotEmpty
              ? disasterAlert.emrgStepNm
              : '긴급재난문자',
          body: disasterAlert.msgCn,
          timestamp: DateTime.tryParse(disasterAlert.crtDt) ?? DateTime.now(),
        );
      }
      // === Firestore 저장 끝 ===

      // 현재 날짜를 YYYYMMDD 형식으로 가져오기
      // Call disaster alerts fetch AFTER weather data and city name are resolved
      _fetchDisasterAlerts(); // currentDate 인자 제거
    } catch (e, stackTrace) {
      print('Error fetching weather data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // Firestore에서 해당 지역의 최근 재난 알림 3개 불러오기 (공개 컬렉션)
  Future<void> _fetchDisasterAlerts() async {
    try {
      // 현재 지역명 구하기 (예: '대전광역시')
      final String? currentRegion = _administrativeArea;
      if (currentRegion == null || currentRegion.isEmpty) {
        print('현재 지역 정보가 없습니다.');
        setState(() {
          latestAlerts = [];
        });
        return;
      }

      // Firestore에서 해당 지역의 최근 재난알림 3개 쿼리
      final querySnapshot = await FirebaseFirestore.instance
          .collection('disaster_alerts')
          .where('region', isEqualTo: currentRegion)
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      final alerts = querySnapshot.docs
          .map((doc) => FirestoreAlert.fromDoc(doc))
          .toList();

      print('Fetched ${alerts.length} alerts for region: $currentRegion');

      setState(() {
        latestAlerts = alerts;
      });
    } catch (e) {
      print('Error fetching disaster alerts from Firestore: $e');
      setState(() {
        errorMessage = '재난 문자 불러오기 실패:  ${e.toString()}';
      });
    }
  }

  // Firestore에 disaster_alerts 자동 저장 함수 (API 데이터 -> Firestore)
  Future<void> saveDisasterAlertToFirestore({
    required String region,
    required String title,
    required String body,
    required DateTime timestamp,
  }) async {
    // 중복 방지: region, title, timestamp가 모두 같은 문서가 이미 있으면 저장하지 않음
    final existing = await FirebaseFirestore.instance
        .collection('disaster_alerts')
        .where('region', isEqualTo: region)
        .where('title', isEqualTo: title)
        .where('timestamp', isEqualTo: Timestamp.fromDate(timestamp))
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      print('이미 동일한 재난알림이 존재합니다. 저장하지 않음.');
      return;
    }
    await FirebaseFirestore.instance.collection('disaster_alerts').add({
      'region': region,
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
    });
    print('Firestore에 재난알림 저장 완료: $region, $title, $timestamp');
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

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

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

                // 재난 알림 섹션
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AlarmScreen(),
                      ),
                    );
                  },
                  child: DisasterAlertSection(
                    alerts: latestAlerts
                        .map(
                          (alert) => {
                            'title': alert.title,
                            'message': alert.body,
                            'time': DateFormat(
                              'h:mm a',
                            ).format(alert.timestamp),
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
