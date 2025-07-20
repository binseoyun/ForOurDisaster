//대설
import 'package:flutter/material.dart';

class SnowDetailPage extends StatelessWidget {
  const SnowDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대설 행동 요령'),
        backgroundColor: Colors.green.shade200,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              '■ 핵심 행동요령',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '대설은 짧은 시간에 급격히 눈이 쌓이게 되므로 교통 정체·고립, '
              '쌓인 눈의 무게로 인한 시설물 붕괴·전도 등 다양한 피해가 발생될 수 있습니다.\n'
              '사전에 다음과 같이 가족이나 이웃과 함께 준비합니다.',
            ),
            SizedBox(height: 16),

            Text(
              '■ 상세 행동요령',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• 재난 정보를 수신할 수 있도록 준비하고, 거주 지역의 재해위험 요인을 미리 확인합니다.'),
            Text('- 재난정보는 TV, 라디오, 인터넷, 스마트폰 안전디딤돌 앱에서 수신합니다.'),
            Text('  ※ 스마트폰 안전디딤돌 앱 설치를 통해 대설, 풍랑 등 기상특보나 눈사태, 시설물 붕괴 등 재난예ㆍ경보를 수신할 수 있습니다.'),
            Text('- 거주지역의 재해위험 요인(눈사태, 붕괴위험시설물 등)은 과거 피해 자료를 통해 확인합니다.'),
            SizedBox(height: 8),
            Text('• 가족, 이웃과 함께 대피계획을 세웁니다.'),
            Text('- 지역 대피장소와 안전한 이동 방법, 대피요령을 미리 숙지하고 어린이 등 재해약자에게 알려 줍니다.'),
            Text('  ※ 지역의 대피장소는 국민재난안전포털이나 지자체 홈페이지의 임시대피소, 이재민 임시주거시설 등에서 확인할 수 있습니다.'),
            Text('- 가족이 각각 이동할 때를 대비하여 다시 만날 장소를 미리 정합니다.'),
            SizedBox(height: 8),
            Text('• 재난 발생에 대비하여 비상용품을 미리 준비합니다.'),
            Text('- 응급약품, 손전등, 식수, 비상식량, 라디오, 핸드폰 충전기, 휴대용 버너, 연료, 담요 등 비상용품을 미리 한 곳에 준비해 둡니다.'),
            Text('- 차량이 있는 경우에는 연료를 미리 채워 두고, 차량이 없을 경우 차량이 있는 가까운 이웃과 같이 이동할 수 있도록 미리 약속해 둡니다.'),
          ],
        ),
      ),
    );
  }
}
