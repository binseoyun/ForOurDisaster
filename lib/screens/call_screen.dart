import 'package:flutter/material.dart'; //flutter의 기본 위젯 제공
import 'package:url_launcher/url_launcher.dart'; //전화번호 클릭 시 전화 앱 실행
import 'editprofile_screen.dart'; //설정 버튼 누리면 이동할 화면'
import 'package:shared_preferences/shared_preferences.dart'; //연락처가 local에 저장될 수 있게
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class CallScreen extends StatefulWidget {
  //StatefulWidget으로 정의하여, 연락처 추가/삭제 시 UI 업데이트
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  String myEmergencyNumber = '010-0000-1111'; //초기 연락처
  final List<Map<String, String>> addedContacts = []; //사용자가 추가한 이름과 연락처 저장

  @override
  @override
  void initState() {
    super.initState();
    loadContacts(); // 앱 시작 시 로컬 데이터 불러오기
  }

  void _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number); //전화번호 눌렀을 때 tel: URL로 전화 앱 실행
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> saveContacts() async {
    final prefs = await SharedPreferences.getInstance(); //local에 저장되게
    final encodedList = addedContacts
        .map((contact) => jsonEncode(contact))
        .toList();
    await prefs.setStringList('emergency_contacts', encodedList);
  }

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedList = prefs.getStringList('emergency_contacts');
    if (encodedList != null) {
      setState(() {
        addedContacts.clear();
        addedContacts.addAll(
          encodedList.map((item) => Map<String, String>.from(jsonDecode(item))),
        );
      });
    }
  }

  void _showAddContactDialog() {
    if (addedContacts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('긴급 연락처는 최대 5개까지 추가할 수 있습니다.')),
      );
      return;
    }

    final nameController = TextEditingController(); //이름관련
    final numberController = TextEditingController(); //전화번호 관련

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("긴급 연락처 추가"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "이름 입력"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: numberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: "전화번호 입력"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final number = numberController.text.trim();
              if (name.isNotEmpty && number.isNotEmpty) {
                setState(() {
                  //addedContacts.add(controller.text); //입력한 번호는 addedContats에 추가
                  addedContacts.add({'name': name, "number": number});
                });
                saveContacts();
              }
              Navigator.pop(context);
            },
            child: const Text("추가"),
          ),
        ],
      ),
    );
  }

  //일단은 연락처가 local에 저장되게 하고, 나중에는 firebase Firestore로 전환해서 친구들끼리 위치를 공유할 수 있게(Firebase+Cloud Function)

  //추가된 연락처 하나하나를 Row로 출력
  Widget buildContactChip(Map<String, String> contact, int index) {
    return GestureDetector(
      onTap: () => _call(contact['number']!),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 110, 205, 243),

              radius: 12,
              child: Icon(Icons.phone, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              //child: Text(number, style: const TextStyle(fontSize: 14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact['name']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    contact['number']!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            /// 👇 여기! 연락처 삭제 버튼
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              onPressed: () {
                setState(() {
                  addedContacts.removeAt(index); // 연락처 삭제
                });
                saveContacts(); //삭제 후 저장
              },
            ),
          ],
        ),
      ),
    );
  }

  //신고 버튼
  Widget buildMiniButton(
    String label,
    String number,
    IconData icon,
    Color color,
  ) {
    //원형 아이콘, 텍스트 라벨, 전화번호로 구성
    return GestureDetector(
      onTap: () => _call(number),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 18,
              child: Icon(icon, size: 18, color: Colors.black),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              number,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //build() UI 구성
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        //화면 상단 바
        titleSpacing: 16,
        title: const Text(
          '빈서윤',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          //설정 아이콘 => 누르면 ProfileScreen으로 이동
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30), // 상단 여백 추가
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: myEmergencyNumber),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: '나의 긴급 연락처',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showAddContactDialog,
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🔽 추가된 긴급 연락처 표시
            SizedBox(
              height: 300, // 5개 연락처에 대한 고정 높이
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  if (index < addedContacts.length) {
                    return buildContactChip(addedContacts[index], index);
                  } else {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          '비어있음',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 32), //충분한 간격 추가
            // 🔽 통합 안내문
            const Text(
              '긴급신고 통합서비스',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '복잡한 신고전화번호 없이\n112·119·110 세 개 번호로만 전화하면\n긴급신고 또는 민원상담 서비스를 받을 수 있습니다.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 🔽 2x2 버튼
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3, // 버튼 비율 조정
              children: [
                buildMiniButton('긴급 신호 전화', '112', Icons.gavel, Colors.pink.shade100),
                buildMiniButton('민원/상담 전화', '110', Icons.sos, Colors.yellow.shade100),
                buildMiniButton('화재/구급', '119', Icons.local_fire_department, Colors.green.shade100),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE7F0E5),
                  foregroundColor: const Color(0xFF4B6045),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
