import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/editprofile_screen.dart';
import 'screens/navigation_wrapper.dart';
import 'screens/call_screen.dart';
import 'screens/map_screen.dart';
import 'screens/manual_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ForOurDisaster',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      // Firebase 로그인 상태에 따라 초기 화면 분기
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (authSnapshot.hasData) {
            // 로그인된 상태라면 사용자 프로필 정보를 가져와서 분기
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(authSnapshot.data!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen(); // 프로필 로딩 중
                }
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  // 'name' 필드가 비어있으면 최초 로그인으로 간주
                  if (userData['name'] == null || (userData['name'] as String).isEmpty) {
                    return const ProfileScreen(); // 프로필 편집 화면으로 이동
                  }
                }
                // 프로필이 이미 있거나, 데이터를 가져오지 못한 경우 홈으로 이동
                return const NavigationWrapper();
              },
            );
          }
          // 로그인 안된 경우 → 로그인 화면
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const NavigationWrapper(), //하단바 포함 페이지
        '/editprofile': (context) => const ProfileScreen(),
      },
    );
  }
}
