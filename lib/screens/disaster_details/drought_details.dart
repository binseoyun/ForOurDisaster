import 'package:flutter/material.dart';

class DroughtDetailPage extends StatelessWidget {
  const DroughtDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가뭄 행동 요령'),
        backgroundColor: Colors.green.shade200,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('■ 가정에서는'),
          _buildBulletList([
            '제한급수 예고 시 식수를 확보하고 용수 공급 일정을 확인합니다.',
            '세탁할 때는 한꺼번에 빨래를 모아서 합니다.',
            '설거지를 할 때는 물을 틀어 놓지 말고 받아서 사용합니다.',
          ]),
          const SizedBox(height: 24),

          _buildSectionTitle('■ 농촌에서는'),
          _buildBulletList([
            '물을 끌어올 수 있는 시설(수로)이나 물을 퍼올릴 수 있는 장비(양수기) 등을 점검합니다.',
            '물 손실 방지를 위해 논두렁 등을 정비합니다.',
            '토양 수분 증발을 최소화하기 위해 볏짚·비닐 등을 덮습니다.',
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(child: Text(item)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}