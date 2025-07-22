import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; //flutter의 기본 위젯 제공
import 'package:url_launcher/url_launcher.dart'; //전화번호 클릭 시 전화 앱 실행
import 'editprofile_screen.dart'; //설정 버튼 누리면 이동할 화면'
import 'package:shared_preferences/shared_preferences.dart'; //연락처가 local에 저장될 수 있게
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
    final emailController = TextEditingController(); //이메일 관련

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
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: "이메일 입력"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final number = numberController.text.trim();
              final email = emailController.text.trim();

              if (name.isNotEmpty && number.isNotEmpty && email.isNotEmpty) {
                // ✅ 먼저 로컬에 추가
                setState(() {
                  addedContacts.add({
                    'senderName': name,
                    'number': number,
                    'targetEmail': email,
                  });
                });
                await saveContacts();

                // ✅ Firestore에 저장
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  print("로그인이 안 된 상태입니다.");
                  return;
                }
                final freshToken = await user.getIdToken(true);
                print("Cloud Function 호출 직전 토큰: $freshToken");

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('emergencyEmails')
                      .add({
                        'senderName': name,
                        'targetEmail': email,
                        'number': number,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                  print("Firestore 저장 성공!");
                } catch (e) {
                  print("Firestore 저장 실패:$e");
                }

                // ✅ 동의 여부 확인 (단, 알림은 동의했을 때만)
                final agreed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("위치 공유 요청"),
                    content: const Text("위급상황 시 내 위치를 상대방에게 표시되게 하시겠습니까?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("취소"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("동의"),
                      ),
                    ],
                  ),
                );

                if (agreed == true) {
                  // ✅ 로그인 상태 체크
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    // 로그인 필요 안내
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("로그인 후 이용해 주세요.")),
                    );
                    return;
                  }

                  // 🔎 토큰 확인 및 강제 갱신
                  final idToken = await user.getIdToken();
                  print("현재 토큰: $idToken");
                  final freshToken = await user.getIdToken(true);
                  print("갱신된 토큰: $freshToken");

                  // 위치 공유 요청 푸시 알림을 보냅니다.
                  try {
                    // 현재 사용자 가져오기
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      print('❌ 사용자가 로그인되어 있지 않습니다.');
                      return;
                    }
                    
                    // ID 토큰 가져오기
                    final idToken = await user.getIdToken();
                    
                    // 명시적으로 리전을 지정하여 Firebase Functions 인스턴스 생성
                    final functions = FirebaseFunctions.instanceFor(region: 'asia-northeast3');
                    
                    // Functions 호출 옵션 설정
                    final callable = functions.httpsCallable(
                      'sendLocationRequest',
                      options: HttpsCallableOptions(
                        timeout: const Duration(seconds: 30),
                      ),
                    );
                    
                    print("🔹 함수 호출 시도: targetEmail=$email, senderName=$name, number=$number");
                    
                    // 인증 헤더와 함께 함수 호출
                    final result = await callable.call(<String, dynamic>{
                      'targetEmail': email,
                      'senderName': name,
                      'number': number,
                      'auth': {
                        'uid': user.uid,
                        'token': idToken,
                      },
                    });
                    print("Cloud Function 호출 결과: ${result.data}");
                  } catch (e, stackTrace) {
                    print('⚠️ Cloud Function 호출 실패');
                    print('에러 타입: ${e.runtimeType}');
                    print('에러 메시지: $e');
                    print('스택 트레이스: $stackTrace');
                    
                    if (e is FirebaseFunctionsException) {
                      print('에러 코드: ${e.code}');
                      print('에러 상세: ${e.details}');
                      print('스택: ${e.stackTrace}');
                    }
                  }
                } else {
                  print("🙅 위치 공유 요청은 하지 않았습니다.");
                }

                // ✅ 마지막으로 다이얼로그 닫기
                Navigator.pop(context);
              }
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
                    contact['senderName']!,
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

  // 알림 설정 가져오기
  Future<bool> _getNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('disaster_alert_enabled') ?? true;
  }

  // 알림 설정 저장
  Future<void> _saveNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('disaster_alert_enabled', value);
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
          // 알림 설정 토글 스위치
          FutureBuilder<bool>(
            future: _getNotificationPreference(),
            builder: (context, snapshot) {
              final isEnabled = snapshot.data ?? true;
              return Switch(
                value: isEnabled,
                onChanged: (value) async {
                  await _saveNotificationPreference(value);
                  setState(() {});
                },
                activeColor: Colors.blue,
              );
            },
          ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                buildMiniButton(
                  '긴급 신호 전화',
                  '112',
                  Icons.gavel,
                  Colors.pink.shade100,
                ),
                buildMiniButton(
                  '민원/상담 전화',
                  '110',
                  Icons.sos,
                  Colors.yellow.shade100,
                ),
                buildMiniButton(
                  '화재/구급',
                  '119',
                  Icons.local_fire_department,
                  Colors.green.shade100,
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (Route<dynamic> route) => false,
                  );
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
