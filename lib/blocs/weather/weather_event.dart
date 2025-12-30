part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class FetchWeatherEvent extends WeatherEvent {
  final String city;
  FetchWeatherEvent({
    required this.city,
  });

  @override
  List<Object> get props => [city];
}

class FetchWeatherByLocationEvent extends WeatherEvent {
  @override
  List<Object> get props => [];
}
