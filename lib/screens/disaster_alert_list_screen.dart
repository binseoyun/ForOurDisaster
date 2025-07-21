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

  final List<String> regions = [
    '서울특별시',
    '부산광역시',
    '대구광역시',
    '인천광역시',
    '광주광역시',
    '대전광역시',
    '울산광역시',
    '세종특별자치시',
    '경기도',
    '강원도',
    '충청북도',
    '충청남도',
    '전라북도',
    '전라남도',
    '경상북도',
    '경상남도',
    '제주특별자치도',
  ];

  String selectedRegion = '서울특별시'; // 기본 선택 지역

  @override
  void initState() {
    super.initState();

    selectedRegion = widget.initialRegion ?? '서울특별시'; // 한 번만 초기화
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String regionToUse = selectedRegion; // 여기로
      print('Using region: $regionToUse');

      final rawAlerts = await _disasterService.fetchAllAlerts(
        region: regionToUse,
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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(alert.msgCn),
          SizedBox(height: 4),
          Text(
            alert.formattedTime,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          : Column(
              children: [
                // ① 상단 드롭다운
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedRegion,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedRegion = value;
                        });
                        _loadAlerts(); // 선택된 지역 기준으로 데이터 다시 불러오기
                      }
                    },
                    items: regions.map((region) {
                      return DropdownMenuItem<String>(
                        value: region,
                        child: Text(region),
                      );
                    }).toList(),
                  ),
                ),

                // ② 리스트 영역은 Expanded로 감싸기
                Expanded(
                  child: alerts.isEmpty
                      ? const Center(child: Text("표시할 재난 문자가 없습니다."))
                      : ListView.builder(
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            return _buildAlertItem(alerts[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
