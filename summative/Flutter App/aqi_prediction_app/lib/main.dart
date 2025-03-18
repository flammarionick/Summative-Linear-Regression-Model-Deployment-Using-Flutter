import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';  // For formatting date and time
import 'package:fl_chart/fl_chart.dart'; // For graphing AQI prediction

void main() {
  runApp(AQIApp());
}

class AQIApp extends StatelessWidget {
  const AQIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AQI Prediction',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AQIPredictPage(),
    );
  }
}

class AQIPredictPage extends StatefulWidget {
  const AQIPredictPage({super.key});

  @override
  _AQIPredictPageState createState() => _AQIPredictPageState();
}

class _AQIPredictPageState extends State<AQIPredictPage> {
  // Controllers for TextFields
  final TextEditingController _nmhcController = TextEditingController();
  final TextEditingController _o3Controller = TextEditingController();
  final TextEditingController _no2Controller = TextEditingController();
  final TextEditingController _coController = TextEditingController();

  // Variables for prediction result and time
  String _prediction = "";
  String _timestamp = "";
  bool _isLoading = false;

  // Method to send data to FastAPI and get prediction
  Future<void> _getPrediction() async {
    setState(() {
      _isLoading = true;
    });

    // Validate the inputs
    if (_nmhcController.text.isEmpty || 
        _o3Controller.text.isEmpty || 
        _no2Controller.text.isEmpty || 
        _coController.text.isEmpty) {
      setState(() {
        _prediction = 'Please fill in all fields';
        _timestamp = '';
      });
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (double.tryParse(_nmhcController.text) == null ||
        double.tryParse(_o3Controller.text) == null ||
        double.tryParse(_no2Controller.text) == null ||
        double.tryParse(_coController.text) == null) {
      setState(() {
        _prediction = 'Please enter valid numbers';
        _timestamp = '';
      });
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Proceed with sending the request if validation passes
    final url = 'http://127.0.0.1:8000/predict'; // Your FastAPI URL
    
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        "PT08_S2_NMHC": double.parse(_nmhcController.text),
        "PT08_S5_O3": double.parse(_o3Controller.text),
        "PT08_S4_NO2": double.parse(_no2Controller.text),
        "PT08_S1_CO": double.parse(_coController.text),
      }),
      headers: {
        "Content-Type": "application/json",
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final predictionData = json.decode(response.body);
      setState(() {
        _prediction = predictionData['predicted_AQI'].toString();
        _timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      });
    } else {
      setState(() {
        _prediction = 'Error: Unable to fetch prediction.';
        _timestamp = '';
      });
    }
  }

  Color _getAqiColor() {
    double aqi = double.tryParse(_prediction) ?? 0;
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }

  String _getHealthWarning() {
    double aqi = double.tryParse(_prediction) ?? 0;
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for sensitive groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AQI Prediction"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Air quality index section
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
                      _prediction.isNotEmpty ? _prediction : 'Enter values and click Predict',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: _getAqiColor()),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _timestamp.isNotEmpty ? 'Last updated: $_timestamp' : '',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _getHealthWarning(),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            
            // Input fields for AQI prediction
            _buildInputField('PT08_S2_NMHC', _nmhcController),
            _buildInputField('PT08_S5_O3', _o3Controller),
            _buildInputField('PT08_S4_NO2', _no2Controller),
            _buildInputField('PT08_S1_CO', _coController),
            
            SizedBox(height: 30),
            
            // Predict button
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _getPrediction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('Predict AQI'),
                  ),
            SizedBox(height: 20),

            // Optional: Prediction graph
            _prediction.isNotEmpty
                ? SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: true),
                        minX: 0,
                        maxX: 10,
                        minY: 0,
                        maxY: double.tryParse(_prediction) ?? 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(0, double.tryParse(_prediction) ?? 0),
                              FlSpot(1, double.tryParse(_prediction) ?? 0),
                            ],
                            isCurved: true,
                            color: Color(0xFF0000FF), // Blue color defined explicitly
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}






