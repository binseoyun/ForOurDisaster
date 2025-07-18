import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //나중에 firestore 만들어서 연결해야함

class ProfileScreen extends StatefulWidget { //프로필 화면을 구성하는 StatefulWidget
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> { //상태 클래스, 이 클래스 안에서 UI 구성과 상태 변화 관리
  //각각의 입력 필드 값을 다루기 위한 TextEditingController
  final _nameController = TextEditingController(); //이름
  final _emailController = TextEditingController(); //이메일
  final _passwordController = TextEditingController(); //password
  String _selectedCountry = 'Nigeria'; //국가

//드롭다운에 표시될 국가 목록 리스트
  final List<String> countries = ['Nigeria', 'South Korea', 'USA', 'Japan', 'Germany'];

  Future<void> _saveToFirebase() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목을 입력해주세요.')),
      );
      return;
    }

//firestore 버전 업그레이드 해서 연동 필요(데이터 설계해야함)
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'name': name,
        'email': email,
        'password': password,
        'country': _selectedCountry,
        'timestamp': FieldValue.serverTimestamp(),
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장 완료!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

//build() 매서드 : 화면 UI 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //상단 앱바 부분
      appBar: AppBar(
        title: const Text("프로필", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: const BackButton(), //왼쪽 상단의 <- 아이콘을 의미
      ),
      //body 전체 입력 폼
      body: Padding(
        padding: const EdgeInsets.all(20), //모든 요소에 패딩을 줘서 여백을 확보
        child: Column( //전체 화면은 cloumn으로 구성
          children: [
            _buildLabel("Name"), //Name이라는 텍스트를 좌측 정렬로 출력
            TextField( //사용자 입력을 받을 수 있는 필드
              controller: _nameController, //controller를 사용해서 사용자가 입력한 내용을 가져옴
              decoration: _inputDecoration("Kim Do Young"), //decoration은 힌트 텍스트 및 테두리 스타일
            ),
            const SizedBox(height: 16),
            _buildLabel("Email"),
            TextField(
              controller: _emailController,
              decoration: _inputDecoration("doyoung@gmail.com"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildLabel("Password"),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration("**********"),
            ),
            const SizedBox(height: 16),
            _buildLabel("Country/Region"),
            DropdownButtonFormField<String>( //DropdownButtonFormField는 사용자에게 국가 목록을 선택하게 함
              value: _selectedCountry,
              decoration: _inputDecoration("Select Country"),
              items: countries
                  .map((country) =>
                      DropdownMenuItem(value: country, child: Text(country)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() { //선택된 값이 바뀌면 setState로 화면 갱신
                    _selectedCountry = value;
                  });
                }
              },
            ),
            const Spacer(), //남은 공간을 밀어내어 아래 버튼이 하단에 고정되게 
            ElevatedButton( //저장 버튼
              onPressed: (){
                //나중에 Firebase 저장 로직 작성
              },
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
            )
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

