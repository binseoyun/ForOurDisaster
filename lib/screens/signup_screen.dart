import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

//사용자가 이름,이메일,비밀번호를 입력하고 FirebaseAuth로 회원가입 시 자동으로 id가 생성=> uid를 키로 하여 Firestore에 users 컬렉션에 문서 생성


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: '이메일',
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
                    //TODO: 회원가입 로직
                    final name=_nameController.text.trim();
                    final email=_emailController.text.trim();
                    final password=_passwordController.text.trim();
                    
                    //Firebase Authentication에 회원가입
                    //Firestore에 users 컬렉션에 문서 추가(uid 기반)
                    //성공하면 => 로그인 화면 이동

                   //아직 입력이 안되어 있다면
                    if (name.isEmpty || email.isEmpty || password.isEmpty) {
                       ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("모든 항목을 입력해주세요.")),
                       );
                      return;
                      }
                      
                try {
                // 1. Firebase Authentication에 회원가입
    
                     final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

    // 2. Firestore에 사용자 문서 생성
    
    await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'country': '', // 기본 값
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 3. 로그인 화면으로 이동
    Navigator.pushReplacementNamed(context, '/login');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("회원가입 실패: $e")),
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
