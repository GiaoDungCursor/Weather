import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import '../exceptions/weather_exception.dart';
import '../models/weather.dart';
import 'http_error_handler.dart';

class WeatherApiServices {
  final http.Client httpClient;
  WeatherApiServices({
    required this.httpClient,
  });

  Future<Map<String, dynamic>> getCoordinates(String city) async {
    final Uri uri = Uri(
      scheme: 'https',
      host: kGeocodingHost,
      path: '/v1/search',
      queryParameters: {
        'name': city,
        'count': '1',
      },
    );

    try {
      final http.Response response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(httpErrorHandler(response));
      }

      final responseBody = json.decode(response.body);

      if (responseBody['results'] == null || responseBody['results'].isEmpty) {
        throw WeatherException('Cannot get the location of $city');
      }

      final result = responseBody['results'][0];
      return {
        'name': result['name'],
        'latitude': result['latitude'],
        'longitude': result['longitude'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Weather> getWeather(double lat, double lon, String cityName) async {
    final Uri uri = Uri(
      scheme: 'https',
      host: kWeatherHost,
      path: '/v1/forecast',
      queryParameters: {
        'latitude': '$lat',
        'longitude': '$lon',
        'current': 'temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m',
        'hourly': 'temperature_2m,weather_code',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
      },
    );

    try {
      final http.Response response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(httpErrorHandler(response));
      }

      final weatherJson = json.decode(response.body);

      // We need to inject the city name because the API doesn't return it in the weather response
      final Weather weather = Weather.fromJson(weatherJson);
      
      // Return a new Weather instance with the city name from arguments
      return Weather(
        weatherStateName: weather.weatherStateName,
        weatherStateAbbr: weather.weatherStateAbbr,
        created: weather.created,
        minTemp: weather.minTemp,
        maxTemp: weather.maxTemp,
        theTemp: weather.theTemp,
        humidity: weather.humidity,
        windSpeed: weather.windSpeed,
        title: cityName,
        woeid: weather.woeid,
        lastUpdated: weather.lastUpdated,
        daily: weather.daily,
        hourly: weather.hourly,
      );
    } catch (e) {
      rethrow;
    }
  }
}
