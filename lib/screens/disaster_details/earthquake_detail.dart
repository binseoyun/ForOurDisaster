import 'package:flutter/material.dart';

class EarthquakeDetailPage extends StatelessWidget {
const EarthquakeDetailPage({super.key});

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

      //앱바 추가해서 뒤로가기 버튼 나오는 지 확인 
      appBar: AppBar(
        title: const Text("지진", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: (){
            //Navigator.pushReplacement(context, './manual_screen.dart')
          },
           icon: const Icon(Icons.arrow_back)),
           
      ),


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
                      "지진",
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
                  infoBox("지진으로 흔들리는 동안은 탁자 아래로 들어가 몸을 보호하고, 탁자 다리를 꼭 잡습니다. "),

                  sectionTitle("상세행동요령"),
                  detailCard(
                    icon: Icons.directions_railway,
                    title: "집안에 있을 경우",
                    desc: "탁자 아래로 들어가 몸을 보호합니다. 흔들림이 멈추면 전기와 가스를 차단하고 문을 열어 출구를 확보한 후,밖으로 나갑니다.",
                  ),
                  detailCard(
                    icon: Icons.directions_walk_sharp,
                    title: "앨리베이터에 있는 경우",
                    desc: "모든 층의 버튼을 눌러 가장 먼저 열리는 층에서 내린 후 계단을 이용합니다.",
                  ),

                 detailCard(
                  icon: Icons.directions_walk,
                  title: "운전을 하고 있는 경우", 
                  desc: "비상등을 켜고 서서히 속도를 줄여 도로 오른쪽에 차를 세우고, 라디오의 정보를 잘 들으면서 키를 꽂아 두고 대피합니다.",
      
                  )
                  ,
                  sectionTitle("주요기관 연락처"),
                  contactCard("소관부서:지진방재관리과", "044-205-5192"),
                 
                ],
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}
