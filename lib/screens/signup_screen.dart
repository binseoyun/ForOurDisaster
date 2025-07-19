import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? emailErrorText;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Title
              const Text(
                'ForOurDisaster',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4B6045),
                  fontFamily: 'Pretendard',
                ),
              ),

              const SizedBox(height: 8),

              //Subtitle
              const Text(
                '안전!!!',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF150502),
                  fontFamily: 'Pretendard',
                ),
              ),

              const SizedBox(height: 40),

              //Full Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: '성함',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //Email
              TextField(
                controller: _emailController,
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      emailErrorText = '이메일을 입력해주세요.';
                    } else if (!isValidEmail(value.trim())) {
                      emailErrorText = '유효하지 않은 이메일 형식입니다.';
                    } else {
                      emailErrorText = null;
                    }
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: '이메일',
                  prefixIcon: Icon(Icons.email_outlined),
                  errorText: emailErrorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '비밀번호',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //SIgnup Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = _nameController.text.trim();
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();

                    if (name.isEmpty || email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('모든 항목을을 채워주세요.')),
                      );
                      return;
                    }

                    if (!isValidEmail(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이메일 형식이 올바르지 않습니다.')),
                      );
                      return;
                    }

                    try {
                      //회원가입
                      await authService.value.signUp(
                        email: email,
                        password: password,
                      );

                      //사용자 이름 설정
                      await authService.value.updateUsername(username: name);

                      //성공 메세지
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('회원가입이 완료되었습니다.')),
                      );

                      //로그인 화면으로 이동
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      print('FirebaseAuthException: ${e.code}, ${e.message}');
                      String message;
                      switch (e.code) {
                        case 'invalid-email':
                          message = '유효하지 않은 이메일 형식입니다다.';
                          break;
                        case 'email-already-in-use':
                          message = '이미 사용 중인 이메일입니다.';
                          break;
                        case 'weak-password':
                          message = '비밀번호는 6자 이상이어야 합니다.';
                          break;
                        default:
                          message = '회원가입 중 오류가 발생했습니다: ${e.code})';
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('예기지 못한 오류가 발생했습니다다: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B6045),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      color: Color(0xFFF9FBFA),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
