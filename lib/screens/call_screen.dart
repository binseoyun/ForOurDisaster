import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'eiditprofile_screen.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  String myEmergencyNumber = '010-0000-1111';
  final List<String> addedContacts = [];

  void _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showAddContactDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("긴급 연락처 추가"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: "전화번호 입력"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  addedContacts.add(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text("추가"),
          ),
        ],
      ),
    );
  }

  

  Widget buildContactChip(String number, int index) {
  return GestureDetector(
    onTap: () => _call(number),
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
            backgroundColor: Colors.purpleAccent,
            radius: 12,
            child: Icon(Icons.phone, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(number, style: const TextStyle(fontSize: 14)),
          ),

          /// 👇 여기! 연락처 삭제 버튼
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: () {
              setState(() {
                addedContacts.removeAt(index); // 연락처 삭제
              });
            },
          ),
        ],
      ),
    ),
  );
}


  Widget buildMiniButton(String label, String number, IconData icon, Color color) {
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
            CircleAvatar(backgroundColor: color, radius: 18, child: Icon(icon, size: 18, color: Colors.black)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(number, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text('빈서윤', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: myEmergencyNumber),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: '나의 긴급 연락처',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showAddContactDialog,
                  icon: const Icon(Icons.add_circle, color: Colors.blue, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 12),



             // 🔽 추가된 긴급 연락처 표시
            if (addedContacts.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...addedContacts.asMap().entries.map(
                (entry) => buildContactChip(entry.value, entry.key),
              ),
            ],



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
              childAspectRatio: 1.8,
              children: [
                buildMiniButton('긴급 신호 전화', '112', Icons.gavel, Colors.pink.shade100),
                buildMiniButton('민원/상담 전화', '110', Icons.sos, Colors.yellow.shade100),
                buildMiniButton('화재/구급', '119', Icons.local_fire_department, Colors.green.shade100),
               
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}
