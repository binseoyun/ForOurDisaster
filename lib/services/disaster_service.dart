import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:formydisaster/models/disaster_alert.dart';
import 'package:intl/intl.dart'; // DateFormat을 위해 추가

class DisasterService {
  // _baseUrl은 이제 더 이상 수정할 필요 없이 이대로 사용합니다.
  final String _baseUrl = 'https://www.safetydata.go.kr/V2/api/DSSP-IF-00247';
  String get _serviceKey => dotenv.env['DISASTER_API_KEY'] ?? '';

  // 재난 문자 API 호출을 위한 공통 로직
  Future<List<Map<String, dynamic>>> _fetchDisasterData({
    required int numOfRows,
    String? region,
    String? crtDt, // HomeScreen에서 넘겨받을 crtDt
    bool includeDateFilter = true, //날짜 필터
  }) async {
    print('_fetchDisasterData called with region: "$region"');

    Map<String, String> queryParams = {
      'serviceKey': _serviceKey,
      'returnType': 'json',
      'numOfRows': numOfRows.toString(), // int를 String으로 변환
      'pageNo': '1', // 페이지 번호는 기본적으로 1로 설정
    };

    if (region != null && region.isNotEmpty) {
      print('Using region name as is for API: "$region"');
      queryParams['rgnNm'] = region;
    }

    // 날짜 필터를 포함하는 경우에만 crtDt 파라미터 추가
    if (includeDateFilter) {
      // crtDt가 null이거나 비어있으면 현재 날짜로 설정
      String actualCrtDt =
          crtDt ?? DateFormat('yyyyMMdd').format(DateTime.now());
      if (actualCrtDt.isNotEmpty) {
        queryParams['crtDt'] = actualCrtDt;
      }
    }

    // Uri.https를 사용하여 전체 URL을 직접 파싱합니다.
    // _baseUrl에 이미 모든 경로가 포함되어 있으므로, queryParams만 추가하면 됩니다.
    final Uri uri = Uri.https(
      _baseUrl
          .replaceFirst('https://', '')
          .split('/')
          .first, // 호스트 (예: www.safetydata.go.kr)
      _baseUrl
          .replaceFirst('https://', '')
          .substring(
            _baseUrl.replaceFirst('https://', '').indexOf('/'),
          ), // 경로 (예: /V2/api/DSSP-IF-00247)
      queryParams,
    );

    print('Disaster API Request URL: $uri');

    try {
      final response = await http.get(uri);
      print('Disaster API Response Status: ${response.statusCode}');
      print('Disaster API Response Body: ${response.body}'); // 응답 본문 확인용

      if (response.statusCode != 200) {
        throw Exception('재난 문자 요청 실패: ${response.statusCode}');
      }

      final Map<String, dynamic> jsonData = json.decode(
        utf8.decode(response.bodyBytes),
      ); // 한글 깨짐 방지

      // API 응답 구조 맞춰서...
      final dynamic bodyData = jsonData['body'];

      if (bodyData is List) {
        return List<Map<String, dynamic>>.from(bodyData);
      } else if (bodyData is Map) {
        // 단일 객체로 올 경우 (totalCount가 1일 때)
        return [Map<String, dynamic>.from(bodyData)];
      } else {
        print(
          'Disaster API: Unexpected response structure or "body" key not found or empty.',
        );
        return [];
      }
    } catch (e) {
      print('Error fetching disaster data: $e');
      rethrow;
    }
  }

  // 홈 최근 알림 일부 (3개)
  Future<List<Map<String, dynamic>>> fetchLatestAlerts({
    String? region,
    String? crtDt,
  }) async {
    return _fetchDisasterData(
      numOfRows: 3,
      region: region,
      crtDt: crtDt,
      includeDateFilter: true,
    );
  }

  // 재난문자 상세 조회 페이지의 최근 모든 알림 (날짜 상관없이 최신순)
  Future<List<DisasterAlert>> fetchAllAlerts({
    String? region,
    String? crtDt,
  }) async {
    final List<Map<String, dynamic>> rawData = await _fetchDisasterData(
      numOfRows: 1000,
      region: null, // Always fetch all regions and filter client-side
      crtDt: null,
      includeDateFilter: false,
    );

    // Convert to DisasterAlert objects
    List<DisasterAlert> alerts = rawData
        .map((json) => DisasterAlert.fromJson(json))
        .toList();

    // Filter by region if specified
    if (region != null && region.isNotEmpty) {
      alerts = alerts.where((alert) {
        // Check if the alert's region contains the selected region name
        return alert.rcptnRgnNm.contains(region);
      }).toList();
    }

    // Sort by date (newest first)
    alerts.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.crtDt);
        final dateB = DateTime.parse(b.crtDt);
        return dateB.compareTo(dateA);
      } catch (e) {
        print('Error sorting alerts: $e');
        return 0;
      }
    });

    return alerts.take(100).toList();
  }
}
