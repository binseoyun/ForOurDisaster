import 'package:flutter/material.dart';

class EarthquakeDetailPage extends StatelessWidget {
  const EarthquakeDetailPage({super.key});

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _buildSubsection(String title, List<String> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ...items.map((text) => Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                child: Text('• $text'),
              )),
          const SizedBox(height: 12),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지진 행동 요령'),
        centerTitle: true,
        backgroundColor: Colors.green.shade200,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('■ 핵심 행동요령'),
          _buildSubsection('', [
            '지진으로 흔들리는 동안은 탁자 아래로 들어가 몸을 보호하고, 탁자 다리를 꼭 잡습니다.',
            '흔들림이 멈추면 전기와 가스를 차단하고, 문을 열어 출구를 확보합니다.',
            '건물 밖으로 나갈 때에는 계단을 이용하여 신속하게 이동합니다. (엘리베이터 사용 금지)',
          ]),

          const Divider(),

          _buildSectionTitle('■ 상세 행동요령'),

          _buildSubsection('<집안에 있을 경우>', [
            '탁자 아래로 들어가 몸을 보호합니다.',
            '흔들림이 멈추면 전기와 가스를 차단하고 문을 열어 출구를 확보한 후, 밖으로 나갑니다.',
          ]),

          _buildSubsection('<집밖에 있을 경우>', [
            '떨어지는 물건에 대비하여 가방이나 손으로 머리를 보호합니다.',
            '건물과 거리를 두고 운동장이나 공원 등 넓은 공간으로 대피합니다.',
          ]),

          _buildSubsection('<엘리베이터에 있을 경우>', [
            '모든 층의 버튼을 눌러 가장 먼저 열리는 층에서 내린 후 계단을 이용합니다.',
            '* 지진 시 엘리베이터를 타면 안 됩니다.',
          ]),

          _buildSubsection('<운전을 하고 있는 경우>', [
            '비상등을 켜고 서서히 속도를 줄여 도로 오른쪽에 차를 세웁니다.',
            '라디오의 정보를 들으면서 키를 꽂아 둔 채 대피합니다.',
          ]),

          _buildSubsection('<산이나 바다에 있을 경우>', [
            '산사태, 절벽 붕괴에 주의하고 안전한 곳으로 대피합니다.',
            '해안에서 지진해일 특보가 발령되면 높은 곳으로 이동합니다.',
          ]),

          const Divider(),

          _buildSectionTitle('■ 주요기관 연락처'),
          _buildSubsection('', [
            '재난신고 119, 범죄신고 112, 민원 상담 110',
            '소관부서: 지진방재관리과 (044-205-5192)',
          ]),
        ],
      ),
    );
  }
}
