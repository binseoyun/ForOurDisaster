//지진
import 'package:flutter/material.dart';

class EarthquakeDetailPage extends StatelessWidget {
  const EarthquakeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지진 행동 요령'),
        backgroundColor: Colors.green.shade200,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              '■ 지진이 발생하면 이렇게 대피합니다.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. 지진으로 흔들릴 때는?'),
            Text('∙ 탁자 아래로 들어가 몸을 보호하고, 탁자 다리를 꼭 잡습니다.'),
            SizedBox(height: 8),
            Text('2. 흔들림이 멈췄을 때는?'),
            Text('∙ 전기와 가스를 차단하고, 문을 열어 출구를 확보합니다.'),
            SizedBox(height: 8),
            Text('3. 건물 밖으로 나갈 때는?'),
            Text('∙ 계단을 이용해 이동합니다. (엘리베이터 사용 금지)'),
            Text('※ 엘리베이터 안에 있을 경우, 모든 층 버튼을 눌러 먼저 열리는 층에서 내립니다.'),
            SizedBox(height: 8),
            Text('4. 건물 밖으로 나왔을 때는?'),
            Text('∙ 가방이나 손으로 머리를 보호하고, 건물과 거리를 두고 이동합니다.'),
            SizedBox(height: 8),
            Text('5. 대피 장소를 찾을 때는?'),
            Text('∙ 떨어지는 물건을 피하며 운동장, 공원 등 넓은 공간으로 대피합니다.'),
            SizedBox(height: 8),
            Text('6. 대피 장소에 도착한 후에는?'),
            Text('∙ 라디오나 안내 방송 등 공식 정보를 따릅니다.'),

            SizedBox(height: 16),
            Text(
              '■ 장소에 따라 이렇게 행동합니다.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. 집안에 있을 경우'),
            Text('∙ 탁자 아래로 들어가 몸을 보호하고, 흔들림이 멈추면 출구 확보 후 대피합니다.'),
            SizedBox(height: 4),
            Text('2. 집밖에 있을 경우'),
            Text('∙ 머리를 보호하며 넓은 공간으로 대피합니다.'),
            SizedBox(height: 4),
            Text('3. 엘리베이터에 있을 경우'),
            Text('∙ 모든 층 버튼을 눌러 가장 먼저 열리는 층에서 내려 계단 이용'),
            SizedBox(height: 4),
            Text('4. 학교에 있을 경우'),
            Text('∙ 책상 아래로 들어가 책상 다리를 잡고, 운동장으로 대피'),
            SizedBox(height: 4),
            Text('5. 백화점, 마트에 있을 경우'),
            Text('∙ 진열장 낙하물로부터 몸 보호 → 기둥 근처 → 흔들림 멈추면 대피'),
            SizedBox(height: 4),
            Text('6. 극장‧경기장에 있을 경우'),
            Text('∙ 자리에 머무르며 소지품으로 보호 → 침착히 안내에 따라 대피'),
            SizedBox(height: 4),
            Text('7. 전철을 타고 있을 경우'),
            Text('∙ 손잡이 또는 기둥을 잡고 넘어지지 않도록 → 멈추면 안내 따름'),
            SizedBox(height: 4),
            Text('8. 운전 중에는'),
            Text('∙ 비상등 켜고 서서히 감속 후 도로 오른쪽 정차 → 키 꽂아두고 대피'),
            SizedBox(height: 4),
            Text('9. 산이나 바다에 있을 경우'),
            Text('∙ 산사태, 절벽 붕괴 주의 → 안전한 곳으로 이동'),
            Text('∙ 지진해일 특보 시 해안가에서 높은 곳으로 이동'),

            SizedBox(height: 16),
            Text(
              '■ 몸이 불편하신 분은 이렇게 행동합니다.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. 시력이 좋지 않거나 시각장애가 있는 경우'),
            Text('∙ 라디오/TV 등으로 상황 파악 → 낙하물, 장애물 확인하며 이동'),
            Text('∙ 화기 점검 등은 주변 사람에게 요청'),
            SizedBox(height: 4),
            Text('2. 거동이 불편하거나 지체장애가 있는 경우'),
            Text('∙ 이웃과 함께 대피 → 휠체어는 브레이크 후 숙이고 머리 보호'),
            Text('∙ 고립 시 자택 위치를 알려 구조 요청'),
            SizedBox(height: 4),
            Text('3. 청각장애가 있는 경우'),
            Text('∙ 자막방송, 휴대폰 통해 정보 수집 → 호루라기 등으로 신호'),
            Text('∙ 의사 표현 어려우면 종이, 펜 사용'),
            SizedBox(height: 4),
            Text('4. 정신이 불안정하거나 발달장애가 있는 경우'),
            Text('∙ 급히 뛰지 않고 미리 정한 행동지침을 따름 → 주변 사람에게 요청'),

            SizedBox(height: 16),
            Text(
              '■ 어린이와 함께 있을 때는 이렇게 행동합니다.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. 유모차보다 아기띠를 사용'),
            Text('∙ 손이 자유로운 아기띠로 보호하며 대피'),
            SizedBox(height: 4),
            Text('2. 신발을 신긴 후 안고 대피'),
            Text('∙ 잔해나 유리 등 위험으로부터 보호'),
            SizedBox(height: 4),
            Text('3. 손을 꼭 잡고 행동요령 반복 안내'),
            Text('∙ 혼란 속에서 헤어지지 않도록 하고 계속 말해주며 안내'),
          ],
        ),
      ),
    );
  }
}
