import 'package:flutter/material.dart';
import '../models/disaster_alert.dart';
import '../services/disaster_service.dart';

class DisasterAlertListScreen extends StatefulWidget {
  final String? initialRegion;

  const DisasterAlertListScreen({super.key, this.initialRegion});

  @override
  State<DisasterAlertListScreen> createState() =>
      _DisasterAlertListScreenState();
}

class _DisasterAlertListScreenState extends State<DisasterAlertListScreen> {
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
        // crtDt 파라미터 제거 - 날짜 상관없이 최신순으로 모든 재난문자 조회
      );

      setState(() {
        alerts = rawAlerts;
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
    return ListTile(
      title: Text(alert.emrgStepNm),
      subtitle: Text(alert.msgCn),
      trailing: Text(alert.formattedTime),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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