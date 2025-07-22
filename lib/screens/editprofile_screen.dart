import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //나중에 firestore 만들어서 연결해야함
import 'package:firebase_auth/firebase_auth.dart'; //현재 로그인된 사용자의 uid를 불러와야 함
import 'call_screen.dart';

//DropdownButton의 value가 메뉴 항목 중 정확히 하나와 일치하지 않아서 문제 발생
//value 값이 실제로 DropdownMenuItem 리스트에 존재하는 지 중복은 없는지 확인

class ProfileScreen extends StatefulWidget {
  //프로필 화면을 구성하는 StatefulWidget
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //상태 클래스, 이 클래스 안에서 UI 구성과 상태 변화 관리
  //각각의 입력 필드 값을 다루기 위한 TextEditingController
  final _nameController = TextEditingController(); //이름
  final _emailController = TextEditingController(); //이메일
  final _passwordController = TextEditingController(); //password


//Firestore에서 기존 사용자 데이터 불러오기
  Future<void> _loadUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _passwordController.text = data['password'] ?? '';
      // 지역 정보는 이제 editprofile에서 관리하지 않으므로 제거
      setState(() {}); // 화면 반영
    }
  }

  //Firestore에 사용자 데이터 업데이트
  Future<void> _saveToFirebase() async {
    //이 uid를 Firestore 문서의 ID로 사용해 정보를 불러오거나 수정
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if(uid==null) return; //사용자 정보 없으면

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요.')));
      return;
    }

    try {
      //uid는 회원가입 혹은 로그인 할때 Firebase가 자동 발급
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'password': password,
        // 'country' 또는 'regions' 필드는 이제 home_screen에서 관리
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); //기존 문서가 있으면 업데이트, 없으면 생성

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장 완료!')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // 앱 시작 시 데이터 불러오기
  }

  //build() 매서드 : 화면 UI 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //상단 앱바 부분
      appBar: AppBar(
      title: const Text("프로필", style: TextStyle(fontWeight: FontWeight.bold)),
      leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {//call_screen.dart 화면인 CallScreen 클래스로 이동
     //나중에 main에 등록 후 사용
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CallScreen()),
      );
    },
  ),
),

      //body 전체 입력 폼
      body: Padding(
        padding: const EdgeInsets.all(20), //모든 요소에 패딩을 줘서 여백을 확보
        child: Column(
          //전체 화면은 cloumn으로 구성
          children: [
            _buildLabel("Name"), //Name이라는 텍스트를 좌측 정렬로 출력
            TextField(
              //사용자 입력을 받을 수 있는 필드
              controller: _nameController, //controller를 사용해서 사용자가 입력한 내용을 가져옴
              decoration: _inputDecoration("Ms.Kim"), //decoration은 힌트 텍스트 및 테두리 스타일
            ),
            const SizedBox(height: 16),
            _buildLabel("Email"),
            TextField(
              controller: _emailController,
              decoration: _inputDecoration("abc@gmail.com"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildLabel("Password"),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration("**********"),
            ),
            const Spacer(), //남은 공간을 밀어내어 아래 버튼이 하단에 고정되게 
            ElevatedButton( //저장 버튼
              onPressed:_saveToFirebase, //firebase에 저장될 수 있게 저장 함수 호출
            
            //firebase_auth를 통해 로그인한 사용자 정보 연동, Firestore에 저장된 사용자 불러오기, 수정 시 기존값 불러오기 등
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF918B6E),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "편집 완료",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //헬퍼 메서드
  //입력 필드 위에 라벨  텍스트(Name,Email 등)를 왼쪽 정렬로 보여줌
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  //헬포 메서드
  //TextField와 Dropdown에서 사용할 스타일 정의
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint, //힌트 텍스트
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

//나중에 initialValue 설정해서 사용자 정보 불러오기 시 사용
//validator 추가해서 이메일 형식 검사
//firebase_auth 연동 => 로그인한 유저 정보와 연결 가능
