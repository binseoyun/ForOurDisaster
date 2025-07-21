import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = '02c4f21dbd326429118a892fd7996b38';
  static const String _baseUrl = 'https://api.openweathermap.org/data/3.0/onecall';

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final response = await http.get(Uri.parse('$_baseUrl?lat=$lat&lon=$lon&exclude=minutely,alerts&appid=$_apiKey'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
