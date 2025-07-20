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
    // Safely convert Kelvin to Celsius, providing a default for null inputs
    double kelvinToCelsius(double? kelvin) => (kelvin ?? 273.15) - 273.15;

    // Safely access nested maps and lists, providing empty fallbacks
    final current = json['current'] as Map<String, dynamic>? ?? {};
    
    final weatherList = current['weather'] as List<dynamic>?;
    final currentWeather = weatherList != null && weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>? ?? {}
        : {};

    final dailyList = json['daily'] as List<dynamic>? ?? [];
    final daily = dailyList.isNotEmpty ? dailyList.first as Map<String, dynamic>? ?? {} : {};
    final dailyTemp = daily['temp'] as Map<String, dynamic>? ?? {};

    final hourlyList = json['hourly'] as List<dynamic>? ?? [];
    final firstHour = hourlyList.isNotEmpty ? hourlyList.first as Map<String, dynamic>? ?? {} : {};

    // Determine precipitation type safely
    String pType = 'None';
    if ((current['rain'] as Map<String, dynamic>?)?['1h'] != null) {
      pType = 'Rain';
    } else if ((current['snow'] as Map<String, dynamic>?)?['1h'] != null) {
      pType = 'Snow';
    }

    // Construct the WeatherData object with null-safe access and default values
    return WeatherData(
      description: currentWeather['description'] as String? ?? 'N/A',
      iconCode: currentWeather['icon'] as String? ?? '01d',
      cloudiness: current['clouds'] as int? ?? 0,
      locationName: json['name'] as String? ?? 'Unknown Location',
      tempCurrent: kelvinToCelsius((current['temp'] as num?)?.toDouble()),
      tempHigh: kelvinToCelsius((dailyTemp['max'] as num?)?.toDouble()),
      tempLow: kelvinToCelsius((dailyTemp['min'] as num?)?.toDouble()),
      precipitationProbablity: (firstHour['pop'] as num?)?.toDouble() ?? 0.0,
      precipitationType: pType,
      uvi: (current['uvi'] as num?)?.toDouble() ?? 0.0,
      humidity: current['humidity'] as int? ?? 0,
      windSpeed: (current['wind_speed'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
