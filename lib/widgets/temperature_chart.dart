import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/weather.dart';

class TemperatureChart extends StatelessWidget {
  final List<HourlyWeather> hourlyWeather;

  const TemperatureChart({Key? key, required this.hourlyWeather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hourlyWeather.isEmpty) return SizedBox.shrink();

    // Prepare data points
    List<FlSpot> spots = [];
    for (int i = 0; i < hourlyWeather.length; i++) {
      spots.add(FlSpot(i.toDouble(), hourlyWeather[i].temp));
    }
    
    // Find Min/Max for Y-axis scaling
    double minTemp = hourlyWeather.map((e) => e.temp).reduce((a, b) => a < b ? a : b);
    double maxTemp = hourlyWeather.map((e) => e.temp).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PROJECTION (24H)", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 6, // Show label every 6 hours
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < hourlyWeather.length) {
                           return Padding(
                             padding: const EdgeInsets.only(top: 8.0),
                             child: Text(hourlyWeather[index].time.substring(11, 13), style: TextStyle(color: Colors.white70, fontSize: 10)),
                           );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: hourlyWeather.length.toDouble() - 1,
                minY: minTemp - 2,
                maxY: maxTemp + 2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
