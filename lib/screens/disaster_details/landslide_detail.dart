//산사태
import 'package:flutter/material.dart';

class LandslideDetail extends StatelessWidget {
  const LandslideDetail({super.key});

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
                      "산사태",
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
                  infoBox("대피 방송이 안내 되지 않을 경우 가급적 집에 머무르며 이웃 주민과 수시로 연락합니다. 대피 방송이 안내 된 경우 화재 등 2차 피해 예방을 위해 대피 전에 가스·전기를 차단한 후 안내 장소로 이동합니다."),

                  sectionTitle("상세행동요령"),
                  detailCard(
                    icon: Icons.directions_bus,
                    title: "집(산지 인접 주택,건물)",
                    desc: "토사 유입의 우려가 있는 경우 지하주차장으로 접근을 자제합니다. 대피 이동 중에는 고압전선 인근으로의 접근을 자제합니다.",
                  ),
                  detailCard(
                    icon: Icons.directions_walk_sharp,
                    title: "아영(캠핑) 중",
                    desc: "아영(캠핑)을 멈추고, 마을 회관 등 안전한 곳으로 이동합니다. 대피장소로 이동하기 위해 하천·계류 등을 건너야 할 경우 무리하지 말고, 계곡에서 떨어진 높은 언덕에서 구조를 요청합니다.",
                  ),

                 detailCard(
                  icon: Icons.directions_walk,
                  title: "산행 중", 
                  desc: "산사태는 상부에서 하부로 발생하므로 대피할 때 산사태 방향과 멀어지는 방향의 가장 가까운 높은 곳으로 대피합니다.",
                  )
                  ,
                  sectionTitle("주요기관 연락처"),
                  contactCard("소관부서:산림청 산사태방지과", "042-481-1844"),
                 
                ],
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}
