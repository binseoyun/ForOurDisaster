import 'package:flutter/material.dart';

class FloodedDetailPage extends StatelessWidget {
  const FloodedDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('침수 행동 요령'),
        backgroundColor: Colors.green.shade200,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              '■ 침수 상황 시 상세 행동요령',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),
            Text(
              '＜ 취약지역 거주자 ＞',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('ㆍ (지역주민) 저지대, 상습침수지역 거주자는 기상정보를 수시로 확인하고 대피를 준비합니다.'),
            Text('　※ 사전대피가 필요할 경우 전기, 가스를 차단하고 대피합니다.'),
            Text('ㆍ (상가) 많은 비가 예보되면 전기 시설물(간판 등)을 건물 안으로 옮깁니다.'),
            Text('ㆍ (마을관리자) 마을방송·비상연락망을 통해 외출 자제를 당부하고, 대피 장소를 사전 안내합니다.'),

            SizedBox(height: 16),
            Text(
              '＜ 지하공간 거주･관리･이용자 ＞',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('ㆍ 비상상황에 대비해 방범창 절단용 공구(절단기 등)를 사전에 준비합니다.'),
            Text('ㆍ 부유용품(구명조끼, 튜브, 스티로폼 등)을 준비해 탈출에 대비합니다.'),
            Text('ㆍ 지하역사, 지하주차장 등은 비상구 위치와 대피경로를 평소 익혀둡니다.'),

            SizedBox(height: 16),
            Text(
              '＜ 공동주택 관리자 ＞',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('ㆍ 평상시 물막이 판, 모래주머니, 양수기를 준비하고 설치자도 지정합니다.'),
            Text('　- 비 유입 시 지하공간은 5~10분 내 침수되므로 입구별 담당자를 정합니다.'),
            Text('ㆍ 대피장소를 안내하고 차량 이동은 호우 전까지만 가능하도록 조치합니다.'),
            Text('　- 물막이 판 설치 이후에는 차량 이동이 불가함을 안내합니다.'),
            Text('ㆍ 독거노인, 장애인 등 안전취약계층의 대피 정보를 사전 공지하고 수시로 확인합니다.'),

            SizedBox(height: 16),
            Text(
              '＜ 차량 이용자 ＞',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('ㆍ 비상 탈출용 차량용 망치를 구비합니다.'),
            Text('ㆍ 침수 예상 지역의 지하공간 주차를 금지합니다.'),
            Text('ㆍ 하천변, 해변가, 저지대 주차 차량은 안전한 곳으로 이동시킵니다.'),
            Text('　- 대피 권고 시 둔치 주차장의 차량은 이동하고, 연락처를 차량에 남깁니다.'),
          ],
        ),
      ),
    );
  }
}
