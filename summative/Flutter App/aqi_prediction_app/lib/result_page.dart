import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For graphing AQI prediction
import 'package:intl/intl.dart';  // For formatting date and time

class ResultPage extends StatelessWidget {
  final String prediction;
  final String timestamp;
  final List<double> predictionHistory;
  final List<FlSpot> predictionSpots;

  const ResultPage({
    super.key,
    required this.prediction,
    required this.timestamp,
    required this.predictionHistory,
    required this.predictionSpots,
  });

  Color _getAqiColor(double aqi) {
    if (aqi <= 15) return Colors.green;
    if (aqi <= 25) return Colors.yellow;
    if (aqi <= 35) return Colors.orange;
    if (aqi <= 45) return Colors.red;
    if (aqi <= 50) return Colors.purple;
    return Colors.brown;
  }

  String _getHealthWarning(double aqi) {
    if (aqi <= 15) return 'Good';
    if (aqi <= 25) return 'Moderate';
    if (aqi <= 35) return 'Unhealthy for sensitive groups';
    if (aqi <= 45) return 'Unhealthy';
    if (aqi <= 50) return 'Very Unhealthy';
    return 'Hazardous';
  }

  @override
  Widget build(BuildContext context) {
    double aqi = double.tryParse(prediction) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Prediction Result"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // AQI Card with prediction, timestamp, and health warning
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Air Quality Index (AQI)',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      SizedBox(height: 10),
                      Text(
                        prediction.isNotEmpty ? prediction : 'No Prediction Available',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: _getAqiColor(aqi)),
                      ),
                      SizedBox(height: 10),
                      Text(
                        timestamp.isNotEmpty ? 'Last updated: $timestamp' : '',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _getHealthWarning(aqi),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Prediction graph
              predictionHistory.isNotEmpty
                  ? SizedBox(
                      height: 250,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: true),
                          minX: 0,
                          maxX: predictionHistory.length.toDouble(),
                          minY: 0,
                          maxY: predictionHistory.reduce((a, b) => a > b ? a : b), // Dynamically set maxY
                          lineBarsData: [
                            LineChartBarData(
                              spots: predictionSpots,
                              isCurved: true,
                              color: Color(0xFF0000FF), // Blue color defined explicitly
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: 20),

              // Go back button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to the AQIPredictPage
                },
                child: Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

