//대설
import 'package:flutter/material.dart';

class SnowDetailPage extends StatelessWidget {
  const SnowDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 배경을 흰색으로 통일
      appBar: AppBar(
        title: const Text(
          '대설',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade200,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '핵심 행동요령',
              content: [
                '야외활동을 자제하되, 불가피하게 외출할 경우에는 대중교통을 이용하거나 자동차의 월동 장비를 반드시 구비해야 합니다.',
                '보온 유지를 위해 외투, 장갑, 모자 등을 착용합니다.',
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '상세 행동요령',
              subSections: [
                {
                  'subtitle': '일반 가정',
                  'items': [
                    '눈이 많이 올 때에는 외출을 자제하여 피해를 사전 방지합니다.',
                    '외출 시에는 바닥면이 넓은 운동화나 등산화를 착용하고, 주머니에 손을 넣지 말고 보온 장갑 등을 착용하여 체온을 유지합니다.',
                    '출·퇴근을 평소보다 조금 일찍 하고, 자가용 대신 지하철, 버스 등 대중교통을 이용합니다.',
                  ],
                },
                {
                  'subtitle': '차량 이용자 - 운전 시',
                  'items': [
                    '부득이 차량을 이용할 경우에는 반드시 자동차 월동용품(스노체인, 모래주머니, 염화칼슘, 삽 등)을 휴대합니다.',
                    '장거리 이동 시에는 월동용품, 연료, 식음료 등을 사전에 준비하고 기상상황을 확인합니다.',
                    '결빙 구간에서는 서행하고 안전거리를 두고 운행합니다.',
                  ],
                },
                {
                  'subtitle': '차량 이용자 - 고립된 경우',
                  'items': [
                    '가능한 수단을 통해 구조 연락을 취합니다.',
                    '동승자와 함께 체온을 유지하고 돌아가면서 휴식을 취합니다.',
                    '야간에는 실내등을 켜거나 색깔 있는 옷을 눈 위에 펼쳐 구조 요청 표시를 합니다.',
                  ],
                },
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '주요기관 연락처',
              content: [
                '재난신고 119, 범죄신고 112, 민원 상담 110',
                '행정안전부 중앙재난안전상황실: 044)205-1542~3',
                '소관부서: 자연재난대응과(044~205~5232)',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    List<String>? content,
    List<Map<String, dynamic>>? subSections,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (content != null)
            ...content.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('• $item'),
                )),
          if (subSections != null)
            ...subSections.map((section) => Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '▶ ${section['subtitle']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...List<Widget>.from(
                        section['items'].map<Widget>((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text('  - $item'),
                            )),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
