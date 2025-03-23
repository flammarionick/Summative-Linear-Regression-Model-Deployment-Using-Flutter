import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'result_page.dart';

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
  final TextEditingController _nmhcController = TextEditingController();
  final TextEditingController _o3Controller = TextEditingController();
  final TextEditingController _no2Controller = TextEditingController();
  final TextEditingController _coController = TextEditingController();
  final TextEditingController _noxController = TextEditingController();

  

  String _validationMessage = 'Enter values and click Predict';
  bool _isLoading = false;
  final List<double> _predictionHistory = [];
  final List<FlSpot> _predictionSpots = [];

  Future<void> _getPrediction() async {
    setState(() {
      _isLoading = true;
      _validationMessage = '';
    });

    if (_nmhcController.text.isEmpty ||
        _o3Controller.text.isEmpty ||
        _no2Controller.text.isEmpty ||
        _coController.text.isEmpty ||
        _noxController.text.isEmpty) {
      setState(() {
        _validationMessage = 'Please fill in all fields';
        _isLoading = false;
      });
      return;
    }

    if (double.tryParse(_nmhcController.text) == null ||
        double.tryParse(_o3Controller.text) == null ||
        double.tryParse(_no2Controller.text) == null ||
        double.tryParse(_coController.text) == null ||
        double.tryParse(_noxController.text) == null) {
      setState(() {
        _validationMessage = 'Please enter valid numbers';
        _isLoading = false;
      });
      return;
    }

    final url = 'https://summative-linear-regression-model.onrender.com/predict';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          "PT08_S2_NMHC": double.parse(_nmhcController.text),
          "PT08_S5_O3": double.parse(_o3Controller.text),
          "PT08_S4_NO2": double.parse(_no2Controller.text),
          "PT08_S1_CO": double.parse(_coController.text),
          "PT08_S3_NOx": double.parse(_noxController.text),
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
        double predictionValue = double.tryParse(predictionData['predicted_AQI'].toString()) ?? 0;
        String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

        // Save for graph
        _predictionHistory.add(predictionValue);
        _predictionSpots.add(FlSpot(_predictionHistory.length.toDouble(), predictionValue));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              prediction: predictionValue.toString(),
              timestamp: timestamp,
              predictionHistory: _predictionHistory,
              predictionSpots: _predictionSpots,
            ),
          ),
        );
      } else {
        setState(() {
          _validationMessage = 'Error: Unable to fetch prediction. Status Code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _validationMessage = 'Error: $e';
        _isLoading = false;
      });
    }
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
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Message Container
              Card(
                elevation: 4,
                color: Colors.orange[50],
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    _validationMessage,
                    style: TextStyle(
                      fontSize: 16,
                      color: _validationMessage.contains('Error') || _validationMessage.contains('Please')
                          ? Colors.red
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Input fields
              _buildInputField('PT08_S2_NMHC', _nmhcController),
              _buildInputField('PT08_S5_O3', _o3Controller),
              _buildInputField('PT08_S4_NO2', _no2Controller),
              _buildInputField('PT08_S1_CO', _coController),
              _buildInputField('PT08_S3_NOx', _noxController),

              SizedBox(height: 30),

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
            ],
          ),
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











