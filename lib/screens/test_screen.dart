//더미 JSON 테스트를 위한 파일

// 예: lib/screens/test_screen.dart (또는 main.dart 내부에서 해도 됨)

import 'package:flutter/material.dart';
import '../models/aws_observation.dart';
import '../data/dummy_aws_data.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AwsObservation observation = AwsObservation.fromJson(dummyAwsJson);

    return Scaffold(
      appBar: AppBar(title: const Text('AWS 더미 데이터 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("관측소: ${observation.stationCode}"),
            Text("위치: ${observation.latitude}, ${observation.longitude}"),
            Text("기온: ${observation.avgTemperature} ℃"),
            Text("습도: ${observation.avgHumidity} %"),
            Text("풍속: ${observation.avgWindSpeed} m/s"),
            Text("시간 누적 강수량: ${observation.hourlyRainfall} mm"),
            Text("생성시각: ${observation.createdAt}"),
          ],
        ),
      ),
    );
  }
}
