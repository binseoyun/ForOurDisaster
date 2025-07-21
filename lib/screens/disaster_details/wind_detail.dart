import 'package:flutter/material.dart';

class WindDetailPage extends StatelessWidget {
  const WindDetailPage({super.key});

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
                      "태풍",
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
                  infoBox("태풍이 시작된 때에는 이웃과 함께 신속히 안전한 곳으로 대피하고, 외출을 삼가하며 이웃이나 가족에게 연락하여 안전 여부를 확인하고 위험상황을 알려줍니다."),

                  sectionTitle("상세행동요령"),
                  detailCard(
                    icon: Icons.block,
                    title: "위험 지역 접근 금지",
                    desc: "침수된 도로, 지하차도, 교량,산간,계곡,하천변,해안가,공사장,가로등,신호등,전신주,지하공간 등 위험지역에는 절대 접근하지 않도록 합니다.",
                  ),
                  detailCard(
                    icon: Icons.sensor_window,
                    title: "건물,집안",
                    desc: "건물의 출입문, 창문은 닫아서 파손되지 않도록 하고, 창문이나 유리문에서 되도록 떨어져 있도록 합니다.",
                  ),

                  detailCard(
                    icon: Icons.cloud, 
                    title: "실외", 
                    desc: "운전에 주의하고, 작업 등 야외활동을 중단하고 즉시 실내로 이동합니다."
                    ),
                 
                  sectionTitle("주요기관 연락처"),
                  contactCard("소관부서:자연재난대응과", "044-205-5233"),
                ],
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}
