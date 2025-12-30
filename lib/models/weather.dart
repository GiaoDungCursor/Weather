import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final String weatherStateName;
  final String weatherStateAbbr;
  final String created;
  final double minTemp;
  final double maxTemp;
  final double theTemp;
  final String title;
  final int woeid;
  final DateTime lastUpdated;
  final int humidity;
  final double windSpeed;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  Weather({
    required this.weatherStateName,
    required this.weatherStateAbbr,
    required this.created,
    required this.minTemp,
    required this.maxTemp,
    required this.theTemp,
    required this.title,
    required this.woeid,
    required this.lastUpdated,
    required this.humidity,
    required this.windSpeed,
    required this.hourly,
    required this.daily,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final dailyJson = json['daily'];
    final hourlyJson = json['hourly'];

    // Helper to map WMO code to old abbreviation style
    String _mapWmoCodeToAbbr(int code) {
      if (code == 0) return 'c';
      if (code == 1 || code == 2 || code == 3) return 'lc';
      if (code == 45 || code == 48) return 'hc';
      if (code == 51 || code == 53 || code == 55) return 's'; // drizzle
      if (code == 56 || code == 57) return 's'; // freezing drizzle
      if (code == 61 || code == 63 || code == 65) return 'r'; // rain
      if (code == 66 || code == 67) return 's'; // freezing rain
      if (code == 71 || code == 73 || code == 75) return 'sn'; // snow fall
      if (code == 77) return 'sn'; // snow grains
      if (code == 80 || code == 81 || code == 82) return 'hr'; // rain showers
      if (code == 85 || code == 86) return 'sn'; // snow showers
      if (code == 95 || code == 96 || code == 99) return 't'; // thunderstorm
      return 'c';
    }

    String _mapWmoCodeToName(int code) {
      if (code == 0) return 'Clear Sky';
      if (code == 1 || code == 2 || code == 3) return 'Mainly Clear';
      if (code == 45 || code == 48) return 'Fog';
      if (code == 51 || code == 53 || code == 55) return 'Drizzle';
      if (code == 61 || code == 63 || code == 65) return 'Rain';
      if (code == 71 || code == 73 || code == 75) return 'Snow Fall';
      if (code == 80 || code == 81 || code == 82) return 'Rain Showers';
      if (code == 95 || code == 96 || code == 99) return 'Thunderstorm';
      return 'Clear Sky';
    }

    // Parse Daily
    List<DailyWeather> dailyList = [];
    if (dailyJson != null) {
       for (var i = 0; i < (dailyJson['time'] as List).length; i++) {
         dailyList.add(DailyWeather(
           date: dailyJson['time'][i],
           maxTemp: (dailyJson['temperature_2m_max'][i] as num).toDouble(),
           minTemp: (dailyJson['temperature_2m_min'][i] as num).toDouble(),
           weatherCode: dailyJson['weather_code'][i],
           weatherAbbr: _mapWmoCodeToAbbr(dailyJson['weather_code'][i]),
         ));
       }
    }

    // Parse Hourly
    List<HourlyWeather> hourlyList = [];
    if (hourlyJson != null) {
       // Only take next 24 hours
       for (var i = 0; i < 24 && i < (hourlyJson['time'] as List).length; i++) {
         hourlyList.add(HourlyWeather(
           time: hourlyJson['time'][i],
           temp: (hourlyJson['temperature_2m'][i] as num).toDouble(),
           weatherCode: hourlyJson['weather_code'][i],
           weatherAbbr: _mapWmoCodeToAbbr(hourlyJson['weather_code'][i]),
         ));
       }
    }

    return Weather(
      weatherStateName: _mapWmoCodeToName(current['weather_code']),
      weatherStateAbbr: _mapWmoCodeToAbbr(current['weather_code']),
      created: DateTime.now().toIso8601String(),
      minTemp: (dailyJson['temperature_2m_min'][0] as num).toDouble(),
      maxTemp: (dailyJson['temperature_2m_max'][0] as num).toDouble(),
      theTemp: (current['temperature_2m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      title: '', 
      woeid: -1,
      lastUpdated: DateTime.now(),
      daily: dailyList,
      hourly: hourlyList,
    );
  }

  factory Weather.initial() => Weather(
        weatherStateName: '',
        weatherStateAbbr: '',
        created: '',
        minTemp: 0.0,
        maxTemp: 0.0,
        theTemp: 0.0,
        humidity: 0,
        windSpeed: 0.0,
        title: '',
        woeid: -1,
        lastUpdated: DateTime.now(),
        daily: [],
        hourly: [],
      );

  @override
  List<Object> get props {
    return [
      weatherStateName,
      weatherStateAbbr,
      created,
      minTemp,
      maxTemp,
      theTemp,
      title,
      woeid,
      lastUpdated,
      humidity,
      windSpeed,
      daily,
      hourly,
    ];
  }

  @override
  bool get stringify => true;
}

class DailyWeather {
  final String date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final String weatherAbbr;

  DailyWeather({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.weatherAbbr,
  });
}

class HourlyWeather {
  final String time;
  final double temp;
  final int weatherCode;
  final String weatherAbbr;

  HourlyWeather({
    required this.time,
    required this.temp,
    required this.weatherCode,
    required this.weatherAbbr,
  });
}
