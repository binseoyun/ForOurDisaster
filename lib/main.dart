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
    final String? region = (regionData != null && regionData['regions'] is List && (regionData['regions'] as List).isNotEmpty)
        ? (regionData['regions'] as List).first
        : null;

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
          'region': region,  // Save the region with the alert
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

void setupFCMListeners(BuildContext context) {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final disasterEnabled = prefs.getBool('disaster_alert_enabled') ?? true;

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
    if (user != null) {
      // Get the user's current region from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final regionData = userDoc.data();
      final String? region = (regionData != null && regionData['regions'] is List && (regionData['regions'] as List).isNotEmpty)
          ? (regionData['regions'] as List).first
          : null;

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
            'region': region,  // Save the region with the alert
          });
    }

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
