//기상청_AWS 관측자료

// lib/models/aws_observation.dart

class AwsObservation {
  final String stationCode;           // AWS_OBSVTR_CD: AWS관측소 코드
  final String observationTime;       // OBSRVN_HR: 관측 시간 (년월일시)
  final double latitude;              // LAT: 위도
  final double longitude;             // LOT: 경도
  final double altitude;              // ALTD_METER: 고도 미터

  final double avgWindDirection;      // N10MIN_AVG_WIDIR: 10분 평균 풍향
  final double avgWindSpeed;          // N1MIN_AVG_WISP: 1분 평균 풍속
  final double avgTemperature;        // N1MIN_AVG_AIRTP: 1분 평균 기온
  final double avgHumidity;           // N1MIN_AVG_HMTY: 1분 평균 습도
  final double avgLocalPressure;      // N1MIN_AVG_ACTPL_ATMPR: 1분 평균 현지기압
  final double avgSeaLevelPressure;   // N1MIN_AVG_SLVL_ATMPR: 1분 평균 해면기압

  final double rainfallDetected;      // PCPTTN_PRCP: 강수 감지
  final double hourlyRainfall;        // HR_ACML_RFALL: 시간 누적 강수량
  final double dailyRainfall;         // DAY_ACML_RFALL: 일 누적 강수량

  final String createdAt;             // CRT_DT: 생성 일시

  AwsObservation({
    required this.stationCode,
    required this.observationTime,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.avgWindDirection,
    required this.avgWindSpeed,
    required this.avgTemperature,
    required this.avgHumidity,
    required this.avgLocalPressure,
    required this.avgSeaLevelPressure,
    required this.rainfallDetected,
    required this.hourlyRainfall,
    required this.dailyRainfall,
    required this.createdAt,
  });

  factory AwsObservation.fromJson(Map<String, dynamic> json) {
    return AwsObservation(
      stationCode: json['AWS_OBSVTR_CD'] ?? '',
      observationTime: json['OBSRVN_HR'] ?? '',
      latitude: double.tryParse(json['LAT'] ?? '') ?? 0.0,
      longitude: double.tryParse(json['LOT'] ?? '') ?? 0.0,
      altitude: double.tryParse(json['ALTD_METER'] ?? '') ?? 0.0,
      avgWindDirection: double.tryParse(json['N10MIN_AVG_WIDIR'] ?? '') ?? 0.0,
      avgWindSpeed: double.tryParse(json['N1MIN_AVG_WISP'] ?? '') ?? 0.0,
      avgTemperature: double.tryParse(json['N1MIN_AVG_AIRTP'] ?? '') ?? 0.0,
      avgHumidity: double.tryParse(json['N1MIN_AVG_HMTY'] ?? '') ?? 0.0,
      avgLocalPressure: double.tryParse(json['N1MIN_AVG_ACTPL_ATMPR'] ?? '') ?? 0.0,
      avgSeaLevelPressure: double.tryParse(json['N1MIN_AVG_SLVL_ATMPR'] ?? '') ?? 0.0,
      rainfallDetected: double.tryParse(json['PCPTTN_PRCP'] ?? '') ?? 0.0,
      hourlyRainfall: double.tryParse(json['HR_ACML_RFALL'] ?? '') ?? 0.0,
      dailyRainfall: double.tryParse(json['DAY_ACML_RFALL'] ?? '') ?? 0.0,
      createdAt: json['CRT_DT'] ?? '',
    );
  }
}

//실제 응답이 String 일 수 있어서 double.tryParse()로 변환
//0.0으로 fallback 처리하여 앱이 크래시 나지 않도록 안전하게 설계
//추후에 UI에 바인딩할 때 단위(℃, mm, hPa, m/s) 등을 붙이면 좋음