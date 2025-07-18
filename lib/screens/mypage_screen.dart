import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const EmergencyApp());
}

class MypageScreen extends StatelessWidget {
  const EmergencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '긴급신고 통합서비스',
      home: EmergencyHomePage(),
    );
  }
}

class EmergencyHomePage extends StatelessWidget {
  const EmergencyHomePage({super.key});

  void _call(String number) async {
    final Uri telUri = Uri.parse('tel:$number');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      debugPrint("전화 걸 수 없음: $number");
    }
  }

  Widget _buildEmergencyButton({
    required IconData icon,
    required String label,
    required String number,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _call(number),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 6),
            Text(number, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      appBar: AppBar(
        title: const Text("빈서윤"),
        actions: const [Padding(padding: EdgeInsets.all(12), child: Icon(Icons.settings))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text("비밀번호 수정", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '010-0000-1111',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Text("나의 긴급 연락처", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(width: 6),
                Icon(Icons.person_add_alt_1_outlined, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '010-0000-1111',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "긴급신고 통합서비스",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "복잡한 신고전화번호 없이\n112·119·110 세 개 번호로만 전화하면\n긴급신고 또는 민원상담 서비스를 받을 수 있습니다.",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEmergencyButton(
                  icon: Icons.local_police,
                  label: "긴급신고",
                  number: "112",
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 12),
                _buildEmergencyButton(
                  icon: Icons.support_agent,
                  label: "민원/상담",
                  number: "110",
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 12),
                _buildEmergencyButton(
                  icon: Icons.local_fire_department,
                  label: "화재 구조",
                  number: "119",
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 36),
            const Text("나의 긴급 전화", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _call("01000001111"),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.call, color: Colors.deepPurple),
                    SizedBox(width: 12),
                    Text("긴급 연락처", style: TextStyle(fontSize: 16)),
                    Spacer(),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
