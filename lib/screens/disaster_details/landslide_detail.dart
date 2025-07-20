//산사태
import 'package:flutter/material.dart';

class LandslideDetailPage extends StatelessWidget {
  const LandslideDetailPage({super.key});

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
        title: const Text('산사태 행동 요령'),
        centerTitle: true,
        backgroundColor: Colors.green.shade200,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('■ 핵심 행동요령'),
          _buildSubsection('', [
            '대피 방송이 안내되지 않을 경우 가급적 집에 머무르며 이웃 주민과 수시로 연락합니다.',
            '대피 방송이 안내된 경우 화재 등 2차 피해 예방을 위해 대피 전에 가스·전기를 차단한 후 안내 장소로 이동합니다.',
          ]),

          const Divider(),

          _buildSectionTitle('■ 상세 행동요령'),

          _buildSubsection('<집(산지 인접 주택, 건물)>', [
            '토사 유입의 우려가 있는 경우 지하주차장으로 접근을 자제합니다.',
            '대피 이동 중에는 고압전선 인근으로의 접근을 자제합니다.',
            '건물 안에 머무는 경우 가능한 가장 높은 층, 산과 멀리 있는 공간으로 대피하고, 머리를 보호합니다.',
          ]),

          _buildSubsection('<야영(캠핑) 중>', [
            '야영을 멈추고, 마을 회관 등 안전한 곳으로 이동합니다.',
            '하천·계류를 건너야 할 경우 무리하지 말고, 계곡에서 떨어진 높은 언덕에서 구조를 요청합니다.',
          ]),

          _buildSubsection('<산행 중>', [
            '산행을 멈추고 산지와 멀리 떨어진 곳으로 즉시 대피합니다.',
            '산사태 방향과 가장 멀고 가까운 높은 곳으로 이동합니다.',
            '계곡부를 벗어나 피해 경로 밖으로 대피합니다.',
          ]),

          _buildSubsection('<운전 중>', [
            '저속 운행하며 안전거리를 확보합니다.',
            '산사태 위험 구간은 우회하고 신속히 빠져나갑니다.',
            '대피 중 신호등, 가로등, 고압전선 인근 접근을 자제합니다.',
          ]),

          const Divider(),

          _buildSectionTitle('■ 주요기관 연락처'),
          _buildSubsection('', [
            '재난신고 119, 범죄신고 112, 민원 상담 110',
            '소관부서: 산림청 산사태방지과 (042-481-1844)',
          ]),
        ],
      ),
    );
  }
}
