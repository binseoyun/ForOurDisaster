import 'package:flutter/material.dart';

class DisasterGuideScreen extends StatefulWidget {
  const DisasterGuideScreen({super.key});

  @override
  State<DisasterGuideScreen> createState() => _DisasterGuideScreenState();
}

class _DisasterGuideScreenState extends State<DisasterGuideScreen> {
  final TextEditingController _searchController = TextEditingController();

  // 원본 데이터 리스트
  final List<Map<String, String>> _allDisasters = [
    {'title': '폭우', 'icon': '🌩️'},
    {'title': 'Flood', 'icon': '🌊'},
    {'title': 'Thunderstorm', 'icon': '🌩️'},
    {'title': '지진', 'icon': '🌎'},
    {'title': 'Earthquake', 'icon': '🌎'},
    {'title': '대설', 'icon': '❄️'},
    {'title': '폭염', 'icon': '🔥'},
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> _filteredDisasters = _allDisasters.where((disaster) {
      final title = disaster['title']!.toLowerCase();
      return title.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('자연 재해 행동 요령'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 검색창
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search disaster',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            // 📜 리스트 (스크롤 가능)
            Expanded(
              child: ListView.builder(
                itemCount: _filteredDisasters.length,
                itemBuilder: (context, index) {
                  final disaster = _filteredDisasters[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6EAD5), // 연녹색
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(disaster['icon']!, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Text(disaster['title']!, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      // 바텀 네비게이션은 기존과 동일하게 유지 가능
    );
  }
}
