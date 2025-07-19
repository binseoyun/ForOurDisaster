import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:formydisaster/screens/map_screen.dart';
import 'firebase_options.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mypage_screen.dart';
import 'screens/editprofile_screen.dart';
import 'screens/call_screen.dart';
import 'screens/map_screen.dart';

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

      //home: const ShelterMapScreen(),
      //debugShowCheckedModeBanner: false,


      // Firebase 로그인 상태에 따라 초기 화면 분기
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
           //로그인된 상태라면 HomeScreen()으로 이동
          return const HomeScreen();
          }else{
          // 로그인 안된 경우 → 로그인 화면
          return const LoginScreen();
          }
        },
      ),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        
        '/call': (context) => const CallScreen(),
        '/editprofile': (context) => const ProfileScreen(),
      },

/* routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/map': (context) => const ShelterMapScreen(),
        '/call': (context) => const CallScreen(),
        '/editprofile': (context) => const ProfileScreen(),
      },

*/



      // routes: {
      //   '/': (context) => const SplashScreen(),
      //   '/login': (context) => const LoginScreen(),
      //   '/signup': (context) => const SignupScreen(),
      //   '/home': (context) => const HomeScreen(),
      //   '/mypage': (context) => const MypageScreen(),
      //   '/editprofile': (context) => const ProfileScreen(),
      //},
    );
  }
}
