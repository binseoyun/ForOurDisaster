//산사태
import 'package:flutter/material.dart';

class LandslideDetailPage extends StatelessWidget {
  const LandslideDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('산사태 행동 요령'),
        backgroundColor: Colors.green.shade200,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              '■ 산사태 발생 시에는 이렇게 행동합니다.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            Text(
              '▶ 3.1. 장소에 따라 이렇게 행동합니다.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            Text(
              '3.1.1. 집(산지 인접 주택, 건물)에서 이렇게 행동합니다.',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            Text('○ 대피 방송이 안내되지 않은 경우 가급적 집에 머무르며 이웃 주민과 수시로 연락합니다.'),
            Text('○ 대피 방송이 안내된 경우 가스·전기를 차단한 후 안내 장소로 이동합니다.'),
            Text('○ 옆집 주민을 확인하고 위험 상황을 알립니다.'),
            Text('○ 토사 유입 우려가 있는 지하주차장 접근을 자제합니다.'),
            Text('○ 고압전선 인근 접근을 피합니다.'),
            Text('○ 하천·계류 등 위험한 길은 피하고 튼튼한 건물로 이동합니다.'),
            Text('○ 건물 안에 있을 경우 높은 층, 산과 멀리 있는 공간으로 이동하고 머리를 보호합니다.'),
            Text('○ 고립 시 119에 연락하거나, 소리 지르기, 물건 두드리기로 구조 요청합니다.'),

            SizedBox(height: 12),
            Text(
              '3.1.2. 야영(캠핑) 중에는 이렇게 행동합니다.',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            Text('○ 야영을 멈추고 마을 회관 등 안전한 장소로 이동합니다.'),
            Text('○ 위험한 하천·계류 건너기를 피하고 높은 언덕에서 구조를 요청합니다.'),

            SizedBox(height: 12),
            Text(
              '3.1.3. 산행 중에는 이렇게 행동합니다.',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            Text('○ 산행을 멈추고 산지와 멀리 떨어진 곳으로 즉시 대피합니다.'),
            Text('○ 계곡부를 벗어나 산사태 방향과 가장 멀고 높은 곳으로 이동합니다.'),
            Text('○ 상부에서 하부로 발생하므로 방향을 피해 높은 곳으로 대피합니다.'),
            Text('○ 고립 시 119에 연락하거나 소리 지르기, 옷 흔들기 등으로 구조를 요청합니다.'),

            SizedBox(height: 12),
            Text(
              '3.1.4. 운전 중에는 이렇게 행동합니다.',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            Text('○ 저속 운행하며 안전거리를 확보합니다.'),
            Text('○ 산사태 위험 구간은 우회하고 신속히 빠져나갑니다.'),
            Text('○ 신호등, 가로등, 고압전선 인근 접근을 피합니다.'),

            SizedBox(height: 16),
            Text(
              '▶ 3.2. 대상자에 따라 이렇게 행동합니다.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),
            Text(
              '3.2.1. 어린이와 함께 있을 때는 이렇게 행동합니다.',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            Text('○ 아기를 띠로 안고 머리를 보호합니다.'),
            Text('○ 어린이 손을 꼭 잡고 함께 대피합니다.'),
            Text('○ 반복적으로 행동요령을 말해주며 함께 대처할 수 있게 합니다.'),

            SizedBox(height: 12),
            Text(
              '3.2.2. 노약자나 몸이 불편한 분은 이렇게 행동합니다.',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            Text('○ 가족, 이웃 등 조력자를 미리 정하고 도움을 요청할 방법을 준비합니다.'),
            Text('○ 대피 경로와 장소를 미리 숙지하고, 복용약과 보조기구를 준비합니다.'),
            Text('○ 조력자는 안전 취약계층과 주기적으로 대피 훈련을 하고 행동요령을 교육합니다.'),
            Text('○ 대피 시 노약자·장애인을 적극적으로 돕습니다.'),
            Text('○ 혼자 행동하지 않고, 행정복지센터나 이웃에게 도움을 요청합니다.'),
            Text('○ 움직일 수 없을 경우 안전한 장소에서 구조를 기다립니다.'),
            Text('○ 시각장애인은 라디오, TV 등을 통해 정보를 파악합니다.'),
            Text('○ 청각장애인은 자막방송이나 휴대폰으로 정보를 수집합니다.'),
            Text('○ 정신장애나 발달장애가 있는 경우 주변 사람에게 도움을 요청합니다.'),
          ],
        ),
      ),
    );
  }
}