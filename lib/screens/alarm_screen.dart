import 'package:flutter/material.dart';
import '../models/disaster_alert.dart';
import '../services/disaster_service.dart';

class AlarmScreen extends StatefulWidget {
  final String? initialRegion;

  const AlarmScreen({super.key, this.initialRegion});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final DisasterService _disasterService = DisasterService();

  List<DisasterAlert> alerts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String regionToUse = widget.initialRegion ?? '';
      print('Initial region from widget: ${widget.initialRegion}');

      if (regionToUse.isEmpty || regionToUse == 'Unknown') {
        regionToUse = '서울특별시';
        print('지역명이 Unknown이거나 비어있어 기본 지역인 서울특별시로 설정합니다');
      } else {
        print('Using region: $regionToUse');
      }

      print('Calling fetchAllAlerts with region: $regionToUse');
      final rawAlerts = await _disasterService.fetchAllAlerts(
        region: regionToUse,
      );

      // 최근 7일 이내의 재난 문자만 보여주기
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentAlerts = rawAlerts.where((alert) {
        try {
          final dt = DateTime.parse(alert.crtDt);
          return dt.isAfter(sevenDaysAgo);
        } catch (e) {
          print('날짜 파싱 오류: ${alert.crtDt} - $e');
          return false;
        }
      }).toList();

      setState(() {
        alerts = recentAlerts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  //재난 문자 칸 하나에 들어갈 내용
  Widget _buildAlertItem(DisasterAlert alert) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.emrgStepNm,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(alert.msgCn, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              alert.formattedTime,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("긴급 재난 문자")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text('오류 발생: $errorMessage'))
          : alerts.isEmpty
          ? const Center(child: Text("표시할 재난 문자가 없습니다."))
          : ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                return _buildAlertItem(alerts[index]);
              },
            ),
    );
  }
}