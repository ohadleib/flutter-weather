import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  static const GEO_URL = 'http://api.openweathermap.org/geo/1.0/direct';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));

    print('API Response: ${response.body}');

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemark =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    String? city = placemark[0].locality;

    return city ?? "";
  }

  Future<List<String>> getCitySuggestions(String query) async {
    final response = await http.get(Uri.parse('$GEO_URL?q=$query&limit=5&appid=$apiKey'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<String>((json) => json['name'] as String).toList();
    } else {
      throw Exception('Failed to fetch city suggestions');
    }
  }
}
