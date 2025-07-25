import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:formydisaster/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, //세로 중앙 정렬
            crossAxisAlignment: CrossAxisAlignment.stretch, //가로 최대한 확장
            children: <Widget>[
              const SizedBox(height: 80.0), //상단 여백
              // 로고 텍스트
              Text(
                'ForOurDisaster',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 8.0),

              //슬로건 텍스트
              const Text(
                '안전 어쩌구저쩌구', // 사진에 있는 텍스트
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
              const SizedBox(height: 48.0), // 로고와 입력 필드 사이 여백
              // 이메일 입력 필드
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Your email',
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        color: Colors.grey[600],
                      ), // 메일 아이콘
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0), // 둥근 모서리
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ), // 연한 회색 테두리
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      filled: true, // 배경 채우기
                      fillColor: Colors.white, // 배경색
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 16.0,
                      ), // 내부 패딩
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0), // 이메일과 비밀번호 필드 사이 여백
              //비밀번호 입력 필드
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true, // 비밀번호 숨김
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.grey[600],
                      ), // 자물쇠 아이콘
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0), // 둥근 모서리
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ), // 연한 회색 테두리
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      filled: true, // 배경 채우기
                      fillColor: Colors.white, // 배경색
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 16.0,
                      ), // 내부 패딩
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48.0), // 비밀번호 필드와 버튼 사이 여백
              //로그인 버튼
              ElevatedButton(
                /* onPressed: () {
                  // TODO: 로그인 로직 구현
                  print('Email: ${_emailController.text}');
                  print('Password: ${_passwordController.text}');
                  // 로그인 성공 시 홈 화면으로 이동 (예시)
                  //Navigator.pushReplacementNamed(context, '/home');
                  Navigator.pushReplacementNamed(context,'/editprofile');
                },*/
                onPressed: () async {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  //email과 password가 입력이 안되어 있다면
                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')),
                    );
                    return;
                  }

                  try {
                    // 1. Firebase 인증 시도
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    // 2. Check if profile is complete using AuthService
                    final isComplete = await authService.value
                        .isProfileComplete();

                    // 3. Navigate based on profile completion status
                    if (isComplete) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      Navigator.pushReplacementNamed(context, '/editprofile');
                    }
                  } catch (e) {
                    // 3. 실패하면 에러 메시지 출력
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('로그인 실패: ${e.toString()}')),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF557153), // 사진과 유사한 녹색 계열 색상
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // 둥근 모서리
                  ),
                  elevation: 0, // 그림자 제거
                ),
                child: const Text(
                  'Log in',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // 흰색 텍스트    TODO
                  ),
                ),
              ),
              const SizedBox(height: 24.0), // 버튼과 회원가입 링크 사이 여백
              // 회원가입 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Not a member? ',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signup'); // 회원가입 화면으로 이동
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary, // 테마 색상 사용
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40.0), // 하단 여백
            ],
          ),
        ),
      ),
    );
  }
}
