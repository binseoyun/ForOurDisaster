import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class SlantClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30); //왼쪽 아래
    path.lineTo(size.width, size.height); //오른쪽 아래
    path.lineTo(size.width, 0); //오른쪽 위
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WeatherSection extends StatelessWidget {
  final WeatherData? weatherData;

  const WeatherSection({super.key, required this.weatherData});

  // API 에서 받은 icon 문자열에 따라 이미지 파일명 반환 함수
  String _mapIconName(String iconCode) {
    // OpenWeatherMap 아이콘 코드를 로컬 asset으로 매핑
    switch (iconCode) {
      case '01d': // clear sky day
        return 'lib/assets/sun.png';
      case '01n': // clear sky night
        return 'lib/assets/moon.png';
      case '02d': // few clouds day
        return 'lib/assets/partly-cloudy-day.png';
      case '02n': // few clouds night
        return 'lib/assets/partly-cloud-night.png';
      case '03d':
      case '03n': // scattered clouds
      case '04d':
      case '04n': // broken clouds
        return 'lib/assets/cloudy.png';
      case '09d':
      case '09n': // shower rain
      case '10d':
      case '10n': // rain
        return 'lib/assets/rain.png';
      case '11d':
      case '11n': // thunderstorm
        return 'lib/assets/thunderstorm.png';
      case '13d':
      case '13n': // snow
        return 'lib/assets/snow.png';
      case '50d':
      case '50n': // mist
        return 'lib/assets/wind.png';
      default:
        return 'lib/assets/cloud.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (weatherData == null) {
      return Container(
        width: double.infinity,
        height: 200,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF40513B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    //null 체크 이후 지역 변수에 할당
    final wData = weatherData!;

    return Container(
      width: double.infinity,
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF40513B), //배경색
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          //현재 온도 (좌측 상단)
          Positioned(
            left: 0,
            top: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${wData.tempCurrent.round()}°",
                  style: TextStyle(
                    color: Color(0xFFF9FBFA),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                //최고/최저 온도
                Text(
                  "H:${wData.tempHigh.round()}° L:${wData.tempLow.round()}°",
                  style: const TextStyle(
                    color: Color(0xFFEBEBF5),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                //강수 확률
                Text(
                  "${(wData.precipitationProbablity * 100).round()} % chance of rain",
                  style: TextStyle(color: Color(0xFFF9FBFA), fontSize: 14),
                ),

                //날씨 설명
                Text(
                  wData.description,
                  style: TextStyle(
                    color: Color(0xFFF9FBFA),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

            //지역명 (우측 상단
            Positioned(
              right: 0,
              top: 0,
              child: Text(
                "📍 ${wData.locationName}",
                style: const TextStyle(
                  color: Color(0xFFF9FBFA),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // 날씨 아이콘 (우측 중앙)
          Positioned(
            right: -15,
            top: 20,
            child: Image.asset(
              _mapIconName(wData.iconCode),
              height: 120,
              fit: BoxFit.contain,
            ),
          ),

            // 추가 정보 (우측 하단)
            Positioned(
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Humidity: ${wData.humidity}%",
                    style: const TextStyle(
                      color: Color(0xFFEBEBF5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Wind: ${wData.windSpeed.toStringAsFixed(1)} m/s",
                    style: const TextStyle(
                      color: Color(0xFFEBEBF5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "UV Index: ${wData.uvi.toStringAsFixed(1)}",
                    style: const TextStyle(
                      color: Color(0xFFEBEBF5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
