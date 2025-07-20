//강풍
import 'package:flutter/material.dart';

class WindDetailPage extends StatelessWidget {
  const WindDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('강풍 행동 요령'),
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
              '야외활동을 자제하고 주변의 독거노인 등 건강이 염려되는 분들의 안부를 살피고 '
              '가족이나 이웃과 주변에 있는 사람들과 함께 강풍에 대처합니다.',
            ),
            SizedBox(height: 16),

            Text(
              '■ 강풍 발생 시',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('∙ 노약자, 장애인 등이 거주하는 가정의 경우에는 비상시 대피 방법과 연락 방법을 가족 또는 이웃 등과 사전에 의논합니다.'),
            Text('∙ 대피 시에는 쓰러질 위험이 있는 나무 밑이나 전신주 밑을 피하고 안전한 건물을 이용합니다.'),
            Text('∙ 유리창 근처는 유리가 깨지면 다칠 위험이 있으므로 피하도록 합니다.'),
            Text('∙ 강풍 발생 시 지붕 위나 바깥에서의 작업은 위험하니 자제하고 가급적 집 안팎의 전기 수리도 하지 않습니다.'),
            Text('∙ 운전 중 강풍이 발생할 경우에는 반대편에서 오는 차량을 주의하고 가급적 속도를 줄여 사고를 줄이기 위한 방어운전을 합니다.'),
            Text('∙ 강풍 발생 시 인접한 차로의 차와 안전한 거리를 유지하고, 강한 돌풍은 차를 차선 밖으로 밀어낼 수 있으므로 주의합니다.'),
            Text('∙ 바닷가는 파도에 휩쓸릴 위험이 있으니 나가지 않습니다.'),
            Text('∙ 공사장 작업이나 크레인 운행 등 야외작업을 중지합니다.'),
            Text('∙ 공사장과 같이 날아오는 물건이 있거나 낙하물의 위험이 많은 곳은 가까이 가지 않도록 합니다.'),
            Text('∙ 손전등을 미리 준비하여 강풍에 의한 정전 발생에 대비하고 유리창이 깨지면 파편이 흩어질 수 있으니 신발이나 슬리퍼를 신어 다치지 않도록 합니다.'),
            Text('∙ 강풍이 지나간 후 땅바닥에 떨어진 전깃줄에 접근하거나 만지지 않습니다.'),
            Text('∙ 강풍으로 파손된 전기시설 등 위험 상황을 발견했을 때에는 감전 위험이 있으니 접근하거나 만지지 말고 119나 시·군․구청에 연락하여 조치를 취하도록 합니다.'),
            Text('∙ 강풍 발생으로 전력선이 차량에 닿는 경우, 차 안에 머무르면서 차의 금속 부분에 닿지 않도록 주의하고 주위 사람들에게 위험을 알리고 119에 연락하여 조치를 취하도록 합니다.'),
          ],
        ),
      ),
    );
  }
}