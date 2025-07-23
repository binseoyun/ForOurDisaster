import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/editprofile_screen.dart';
import 'screens/navigation_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

//
@pragma('vm:entry-point')
//백그라운드/종료 상태 수신
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  final disasterEnabled = prefs.getBool('disaster_alert_enabled') ?? true;

  final isDisaster = message.data['type'] == 'disaster_alert';
  final shownInUI = !isDisaster || (isDisaster && disasterEnabled);

  if (!shownInUI) {
    print('백그라운드: 사용자가 재난 알림을 꺼놨으므로 UI에 표시 안 함');
  }

  final title = message.notification?.title ?? '알림';
  final body = message.notification?.body ?? '';
  final now = Timestamp.now();

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Get the user's current region from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final regionData = userDoc.data();
    final String? region =
        (regionData != null &&
            regionData['regions'] is List &&
            (regionData['regions'] as List).isNotEmpty)
        ? (regionData['regions'] as List).first
        : null;

//Firestore의 users/{uid}/notifications에 알람 로그 저장 => 조건이 맞으면 로컬 알림 UI로 표시
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .add({
          'title': title,
          'body': body,
          'timestamp': now,
          'type': message.data['type'] ?? 'unknown',
          'shownInUI': shownInUI,
          'region': region, // Save the region with the alert
        });
  }

  if (shownInUI) {
    await showLocalNotification(title, body);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //.env파일 불러오기기
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeLocalNotifications();

  //FCM 초기화 및 권한 요청
  await setupFCM();

  // 백그라운드 메시지 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

//Flutter local Notifications로 실제 기기에 알람을 띄우는 함수

Future<void> showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'default_channel_id',
        'Default',
        channelDescription: '기본 채널',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0, //알림 ID
    title,
    body,
    platformChannelSpecifics,
  );
}

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // iOS에서는 권한 요청 필요
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('🔔 사용자 알림 권한 허용됨');
  } else {
    print('❌ 알림 권한 거부됨');
  }

  // 토큰 확인 (필수X)
  final token = await messaging.getToken();
  print('📱 FCM Token: $token');
}


//1.상대방이 sendLocationRequest을 통해 Cloud Functions로 알람 보냄
//2.내 앱에서 setupFCMListners()가 메세지 수신
//3.메세지의 type==location_request 이면 다이얼로그 표시
//4.동의 or 취소 선택 => Firestore에 기록
//5.나중에 실제 위치를 전송할 때 이 Firestore 데이터로 상대방이 동의했는지 여부 확ㄷ인

//지금 현재 포그라운드 상태일때 푸시 알람은 보이지만, 동의/거절 같은 UI는 안나옴(AlertDialog 같은 게 없음)
//=>location_request가 들어오먄 다이얼로그 UI 띄우기 추가

//포그라운드 수신(앱이 실행 중일 때 FCM 알림을 직접 수신하여 처리=> Firestore에 기록, 조건이 맞으면 로컬 알림 표시)
void setupFCMListeners(BuildContext context) {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final disasterEnabled = prefs.getBool('disaster_alert_enabled') ?? true;


    final type= message.data['type'] ?? 'unknown'; //type 분기 처리를 위해 선언

    final isDisaster = message.data['type'] == 'disaster_alert';

    //알림 표시 여부 결정
    final shownInUI = !isDisaster || (isDisaster && disasterEnabled);

    if (!shownInUI) {
      print('사용자가 재난 알림을 꺼놨으므로 UI에 표시 안 함');
    }

    final title = message.notification?.title ?? '알림';
    final body = message.notification?.body ?? '';
    final now = Timestamp.now();

    //Firestore에 알림 기록 저장
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("🚫 인증 안 된 상태에서 Firestore에 접근하려 함");
      return;
    }
    final uid = user.uid;

    // Get the user's current region from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final regionData = userDoc.data();
    final String? region =
        (regionData != null &&
            regionData['regions'] is List &&
            (regionData['regions'] as List).isNotEmpty)
        ? (regionData['regions'] as List).first
        : null;

//Firebase의 notification에 저장되어이 있는 필드들
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .add({
          'title': title,
          'body': body,
          'timestamp': now,
          'type': message.data['type'] ?? 'unknown',
          'shownInUI': shownInUI,
          'region': region, // Save the region with the alert
        });
  
  //location_request 타임을 경우=> 다이얼로그
  if (type == 'location_request') {
      final senderName = message.data['fromName'] ?? '알 수 없음';
      final phone = message.data['phoneNumber'] ?? '미제공';
      final fromUid = message.data['fromUid'];
      final targetEmail = message.data['targetEmail'];

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('$senderName님의 위치 공유 요청'),
          content: Text('연락처: $phone\n\n위급 상황 시 위치 공유를 허용하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                print('🙅 위치 공유 거절');

                // ❌ 거절 상태도 기록하려면 아래 사용 (선택)
                await FirebaseFirestore.instance
                    .collection('locationPermissions')
                    .doc(uid)
                    .collection('responses')
                    .add({
                  'fromUid': fromUid,
                  'targetEmail': targetEmail,
                  'allowed': false,
                  'respondedAt': FieldValue.serverTimestamp(),
                });
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                print('✅ 위치 공유 동의');

                // ✅ Firestore에 동의 기록
                await FirebaseFirestore.instance
                    .collection('locationPermissions')
                    .doc(uid) // 수신자 기준으로 저장
                    .collection('responses')
                    .add({
                  'fromUid': fromUid,
                  'targetEmail': targetEmail,
                  'allowed': true,
                  'respondedAt': FieldValue.serverTimestamp(),
                });
              },
              child: const Text('동의'),
            ),
          ],
        ),
      );
    }

  //일반 알림/재난알림일 경우 => 로컬 알림 띄움
    if (shownInUI) {
      await showLocalNotification(title, body);
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ForOurDisaster',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (authSnapshot.hasData) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(authSnapshot.data!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }
                // FCM 필터링 적용
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  setupFCMListeners(context);
                }
                return const NavigationWrapper();
              },
            );
          }
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const NavigationWrapper(),
        '/editprofile': (context) => const ProfileScreen(),
      },
    );
  }
}
