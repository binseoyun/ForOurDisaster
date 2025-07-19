import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ManualScreen extends StatelessWidget {
  ManualScreen({super.key});
  final List<Map<String, String>> disasterList = [
    {
      'title': '폭우',
      'icon': '🌧️',
      'url': 'https://www.safekorea.go.kr/idsiSFK/neo/sfk/cs/contents/prevent/prevent01.html?menuSeq=126',
    },
    {
      'title': 'Flood',
      'icon': '🌊',
      'url': 'https://www.safekorea.go.kr/idsiSFK/neo/sfk/cs/contents/prevent/prevent02.html?menuSeq=126',
    },
    {
      'title': 'Thunderstorm',
      'icon': '🌩️',
      'url': 'https://www.safekorea.go.kr/idsiSFK/neo/sfk/cs/contents/prevent/prevent04.html?menuSeq=126',
    },
    // 필요한 만큼 추가
  ];

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '자연 재해 행동 요령',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Expanded(child: Text("Search disaster", style: TextStyle(color: Colors.grey))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Disaster list
            Expanded(
              child: ListView.builder(
                itemCount: disasterList.length,
                itemBuilder: (context, index) {
                  final item = disasterList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: GestureDetector(
                      onTap: () => _launchURL(item['url']!),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBEBCF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        child: Row(
                          children: [
                            Text(item['icon']!, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 16),
                            Text(item['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
