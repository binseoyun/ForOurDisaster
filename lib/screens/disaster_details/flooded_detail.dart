import 'package:flutter/material.dart';

class FloodedDetailPage extends StatelessWidget {
  const FloodedDetailPage({super.key});

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
                      "침수",
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
                  infoBox("침수된 지역은 절대 접근하지 않습니다."),

                  sectionTitle("상세행동요령"),
                  detailCard(
                    icon: Icons.directions_walk,
                    title: "보행자",
                    desc: "하수도, 맨홀 근처는 추락으로 인한 휩쓸림 사고가 발생할 수 있으므로 접근을 금지합니다.",
                  ),
                  detailCard(
                    icon: Icons.stairs,
                    title: "지하 공간 이용자",
                    desc: "물이 집 안으로 들어오고 있는 상황이라면 출입문부터 개방합니다.",
                  ),

                 detailCard(
                  icon: Icons.directions_car,
                  title: "차량 이용자", 
                  desc: "차량이 침수된 상황에서 외부 수압으로 문이 열리지 않을 때는 좌석 목받침 하단 철재봉을 이용하여 유리창을 깨서 대피합니다.",
      
                  )
                  ,
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
