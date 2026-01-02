import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/constants.dart';
import '../blocs/blocs.dart';
import '../widgets/error_dialog.dart';
import '../widgets/temperature_chart.dart';
import 'search_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _city;

  @override
  void initState() {
    super.initState();
    // Auto fetch weather by location on startup
    context.read<WeatherBloc>().add(FetchWeatherByLocationEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Weather'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              _city = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return SearchPage();
                }),
              );
              print('city: $_city');
              if (_city != null) {
                context
                    .read<WeatherBloc>()
                    .add(FetchWeatherEvent(city: _city!));
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return SettingsPage();
                }),
              );
            },
          ),
        ],
      ),
      body: _showWeather(),
    );
  }

  String showTemperature(double temperature) {
    final tempUnit = context.watch<TempSettingsBloc>().state.tempUnit;

    if (tempUnit == TempUnit.fahrenheit) {
      return ((temperature * 9 / 5) + 32).toStringAsFixed(0) + '°F';
    }
    return temperature.toStringAsFixed(0) + '°C';
  }

  Widget showIcon(String abbr) {
    if (abbr == 'c') {
      return Icon(Icons.wb_sunny, size: 120, color: Colors.amber);
    } else if (abbr == 'lc') {
      return Icon(Icons.wb_cloudy_outlined, size: 120, color: Colors.white70);
    } else if (abbr == 'hc') {
      return Icon(Icons.cloud, size: 120, color: Colors.grey[300]);
    } else if (abbr == 's') {
      return Icon(Icons.grain, size: 120, color: Colors.lightBlueAccent);
    } else if (abbr == 'r') {
      return Icon(Icons.beach_access, size: 120, color: Colors.blue);
    } else if (abbr == 'sn') {
      return Icon(Icons.ac_unit, size: 120, color: Colors.cyanAccent);
    } else if (abbr == 'hr') {
      return Icon(Icons.storm, size: 120, color: Colors.indigoAccent);
    } else if (abbr == 't') {
      return Icon(Icons.flash_on, size: 120, color: Colors.yellowAccent);
    }
    return Icon(Icons.wb_sunny, size: 120, color: Colors.amber);
  }

  LinearGradient _getBackgroundGradient(String abbr) {
    if (abbr == 'c') {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.orange, Colors.orangeAccent],
      );
    } else if (abbr == 'lc' || abbr == 'hc') {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blueGrey, Colors.grey],
      );
    } else if (abbr == 'r' || abbr == 's' || abbr == 'hr') {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.indigo, Colors.blueGrey],
      );
    } else if (abbr == 't') {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.deepPurple, Colors.black87],
      );
    } else if (abbr == 'sn') {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.lightBlue, Colors.blueGrey],
      );
    }
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.blue, Colors.lightBlueAccent],
    );
  }

  Widget _showWeather() {
    return BlocConsumer<WeatherBloc, WeatherState>(
      listener: (context, state) {
        if (state.status == WeatherStatus.error) {
          errorDialog(context, state.error.errMsg);
        }
      },
      builder: (context, state) {
        
        final gradient = _getBackgroundGradient(state.weather.weatherStateAbbr);
        final textColor = Colors.white;

        if (state.status == WeatherStatus.initial) {
          return Container(
            decoration: BoxDecoration(gradient: gradient),
            child: Center(
              child: Text(
                'Select a city',
                style: TextStyle(fontSize: 24.0, color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        if (state.status == WeatherStatus.loading) {
          return Container(
            decoration: BoxDecoration(gradient: gradient),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (state.status == WeatherStatus.error && state.weather.title == '') {
           return Container(
            decoration: BoxDecoration(gradient: gradient),
            child: Center(
              child: Text(
                'Select a city',
                style: TextStyle(fontSize: 24.0, color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(gradient: gradient),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                 SizedBox(height: 40),
                Text(
                  state.weather.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black26, offset: Offset(2, 2))]
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  TimeOfDay.fromDateTime(state.weather.lastUpdated).format(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0, color: textColor.withOpacity(0.8)),
                ),
                SizedBox(height: 50.0),
                showIcon(state.weather.weatherStateAbbr),
                SizedBox(height: 20.0),
                Text(
                  showTemperature(state.weather.theTemp),
                  style: TextStyle(
                    fontSize: 90.0,
                    fontWeight: FontWeight.w200,
                    color: textColor,
                  ),
                ),
                 Text(
                  state.weather.weatherStateName,
                  style: TextStyle(fontSize: 32.0, color: textColor.withOpacity(0.9), fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 40),
                // Glassmorphism Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDetailItem('Min Temp', showTemperature(state.weather.minTemp), Icons.arrow_downward),
                              _buildDetailItem('Max Temp', showTemperature(state.weather.maxTemp), Icons.arrow_upward),
                              _buildDetailItem('Humidity', '${state.weather.humidity}%', Icons.water_drop),
                              _buildDetailItem('Wind', '${state.weather.windSpeed} km/h', Icons.air),
                            ],
                          ),
                          SizedBox(height: 20),
                          // New Chart Widget
                          TemperatureChart(hourlyWeather: state.weather.hourly),
                          
                          SizedBox(height: 20),
                          Divider(color: Colors.white30),
                          SizedBox(height: 10),
                          Text("Hourly Forecast", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          // Hourly Forecast
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: AlwaysScrollableScrollPhysics(),
                              clipBehavior: Clip.none,
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              itemCount: state.weather.hourly.length,
                              itemBuilder: (context, index) {
                                final hour = state.weather.hourly[index];
                                return Container(
                                  width: 85,
                                  margin: EdgeInsets.symmetric(horizontal: 6),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        hour.time.substring(11, 16), 
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Icon(
                                        _getIconData(hour.weatherAbbr), 
                                        color: Colors.white, 
                                        size: 28,
                                      ),
                                      Text(
                                        showTemperature(hour.temp),
                                        style: TextStyle(
                                          color: Colors.white, 
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Text("7-Day Forecast", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                           // Daily Forecast
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: state.weather.daily.length,
                            itemBuilder: (context, index) {
                              final day = state.weather.daily[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      day.date.substring(5, 10), 
                                      style: TextStyle(color: Colors.white, fontSize: 16)
                                    ),
                                    Icon(_getIconData(day.weatherAbbr), color: Colors.white),
                                    Row(
                                      children: [
                                        Text(showTemperature(day.maxTemp), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 10),
                                        Text(showTemperature(day.minTemp), style: TextStyle(color: Colors.white70)),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  IconData _getIconData(String abbr) {
     if (abbr == 'c') return Icons.wb_sunny;
     if (abbr == 'lc') return Icons.wb_cloudy_outlined;
     if (abbr == 'hc') return Icons.cloud;
     if (abbr == 's') return Icons.grain;
     if (abbr == 'r') return Icons.beach_access;
     if (abbr == 'sn') return Icons.ac_unit;
     if (abbr == 'hr') return Icons.storm;
     if (abbr == 't') return Icons.flash_on;
     return Icons.wb_sunny;
  }
  
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70),
        SizedBox(height: 5),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
