import 'package:flutter/material.dart';

class SnowDetailPage extends StatelessWidget {
  const SnowDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // 📌 섹션 제목
    Widget sectionTitle(String title) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: const Color(0xFF0E1B0E),
            ),
          ),
        );

    // 📌 핵심 요령 강조 박스
    Widget infoBox(String text) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE7F3E7),
              borderRadius: BorderRadius.circular(8),
              border: Border(left: BorderSide(width: 4, color: Color(0xFF4E974E))),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF4E974E), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        );

    // 📌 상세 요령 카드
    Widget detailCard({required IconData icon, required String title, required String desc}) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, size: 28, color: const Color(0xFF0E1B0E)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0E1B0E),
                        )),
                    const SizedBox(height: 4),
                    Text(desc,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: const Color(0xFF4E974E),
                          height: 1.4,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 📌 연락처 카드
    Widget contactCard(String title, String phone) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
        ),
        child: Row(
          children: [
            const Icon(Icons.phone_in_talk, color: Color(0xFF4E974E)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      )),
                  const SizedBox(height: 2),
                  Text(phone,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                        fontSize: 13,
                      )),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 (눈 아이콘 + 제목)
            //뒤로 가기 버튼을 눌러서 뒤로 갈 수 있게 아이콘 추가
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                  SizedBox(width: 8),
                  Text(
                      "대설",
                      style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0E1B0E),
                        ),
                      ),
                    ],
                  ),
              ),

           
            Expanded(
              child: ListView(
                children: [
                  sectionTitle("핵심 행동요령"),
                  infoBox("야외활동을 자제하되, 불가피하게 외출할 경우에는 대중교통을 이용하거나 자동차의 월동 장비를 반드시 구비해야 합니다."),

                  sectionTitle("상세행동요령"),
                  detailCard(
                    icon: Icons.directions_subway,
                    title: "일반가정",
                    desc: "출·퇴근을 평소보다 조금 일찍하고, 자가용 대신 지하철,버스 등 대중교통을 이용하세요",
                  ),
                  detailCard(
                    icon: Icons.car_repair,
                    title: "차량 이용자",
                    desc: "부득이 차량을 이용할 경우에는 반드시 자동차 월동용품(스노체인(스프레이 체인), 모래주머니, 염화칼슘, 삽 등)을 휴대합니다.",
                  ),

                  sectionTitle("주요기관 연락처"),
                  contactCard("행정안전부 중앙재난안전상황실", "044)205-1542~3"),
                  contactCard("소관부서:자연재난대응과", "044-205-5232"),
                ],
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}
