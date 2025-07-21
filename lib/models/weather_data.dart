class WeatherData {
  final String description;
  final String iconCode;
  final int cloudiness;
  final String locationName;
  final double tempCurrent;
  final double tempHigh;
  final double tempLow;
  final double precipitationProbablity;
  final String precipitationType;
  final double uvi;
  final int humidity;
  final double windSpeed;

  WeatherData({
    required this.description,
    required this.iconCode,
    required this.cloudiness,
    required this.locationName,
    required this.tempCurrent,
    required this.tempHigh,
    required this.tempLow,
    required this.precipitationProbablity,
    required this.precipitationType,
    required this.uvi,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    //K -> Celcius
    double kelvinToCelsius(double kelvin) => kelvin - 273.15;

    // 현재 날씨 데이터
    final current = json['current'] as Map<String, dynamic>;
    final currentWeather = current['weather'][0] as Map<String, dynamic>;

    // 강수량 확인 (rain 또는 snow 필드가 없을 수 있으므로 안전하게 접근)

    double rainAmount = 0.0;
    double snowAmount = 0.0;
    if (current['rain'] != null) {
      rainAmount = (current['rain']['1h'] as num?)?.toDouble() ?? 0.0;
    }
    if (current['snow'] != null) {
      snowAmount = (current['snow']['1h'] as num?)?.toDouble() ?? 0.0;
    }

    // 강수 유형 결정
    String pType = 'None';
    if (rainAmount > 0) {
      pType = 'Rain';
    } else if (snowAmount > 0) {
      pType = 'Snow';
    }

    // 시간별 데이터에서 강수확률 가져오기 (첫 번째 시간의 데이터 사용)
    double precipProb = 0.0;
    if (json['hourly'] != null && (json['hourly'] as List).isNotEmpty) {
      final firstHour = json['hourly'][0] as Map<String, dynamic>;
      precipProb = (firstHour['pop'] as num?)?.toDouble() ?? 0.0;
    }

    // 일별 데이터에서 최고/최저 온도 가져오기
    double tempMax = kelvinToCelsius(current['temp']);
    double tempMin = kelvinToCelsius(current['temp']);

    if (json['daily'] != null && (json['daily'] as List).isNotEmpty) {
      final today = json['daily'][0] as Map<String, dynamic>;
      final temp = today['temp'] as Map<String, dynamic>;
      tempMax = kelvinToCelsius(temp['max']);
      tempMin = kelvinToCelsius(temp['min']);
    }

    // 위치 이름 - timezone에서 추출하거나 기본값 사용
    String resolvedLocationName = "Unknown Location";
    if (json['timezone'] != null) {
      String timezone = json['timezone'].toString();
      if (timezone.contains('/')) {
        resolvedLocationName = timezone.split('/').last.replaceAll('_', ' ');
      }
    }

    return WeatherData(
      description: currentWeather['description'],
      iconCode: currentWeather['icon'],
      cloudiness: current['clouds'],
      locationName: resolvedLocationName,
      tempCurrent: kelvinToCelsius(current['temp']),
      tempHigh: tempMax,
      tempLow: tempMin,
      precipitationProbablity: precipProb,
      precipitationType: pType,
      uvi: (current['uvi'] as num?)?.toDouble() ?? 0.0,
      humidity: current['humidity'],
      windSpeed: (current['wind_speed'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
