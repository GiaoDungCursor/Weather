import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../exceptions/weather_exception.dart';
import '../models/custom_error.dart';
import '../models/weather.dart';
import '../services/weather_api_services.dart';

class WeatherRepository {
  final WeatherApiServices weatherApiServices;
  WeatherRepository({
    required this.weatherApiServices,
  });

  Future<Weather> fetchWeather(String city) async {
    try {
      final locationData = await weatherApiServices.getCoordinates(city);
      final weather = await weatherApiServices.getWeather(
        locationData['latitude'],
        locationData['longitude'],
        locationData['name'],
      );

      return weather;
    } on WeatherException catch (e) {
      throw CustomError(errMsg: e.message);
    } catch (e) {
      throw CustomError(errMsg: e.toString());
    }
  }

  Future<Weather> fetchWeatherByLocation() async {
    try {
       // 1. Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw WeatherException('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw WeatherException('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw WeatherException(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // 2. Get Position
      final Position position = await Geolocator.getCurrentPosition();

      // 3. Reverse Geocode to get City Name
      // Note: We use geocoding package here
      String cityName = 'Your Location';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          cityName = placemarks.first.locality ?? placemarks.first.administrativeArea ?? 'Unknown';
        }
      } catch (e) {
        // Fallback name if geocoding fails
        print("Geocoding failed: $e");
      }

      // 4. Fetch Weather
      final weather = await weatherApiServices.getWeather(
        position.latitude,
        position.longitude,
        cityName,
      );

      return weather;

    } on WeatherException catch (e) {
      throw CustomError(errMsg: e.message);
    } catch (e) {
      throw CustomError(errMsg: e.toString());
    }
  }
}
