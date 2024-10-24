import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON handling
import 'package:http/http.dart' as http;
import 'package:vuhacathon/globals.dart';

class DriverRatingPage extends StatefulWidget {
  const DriverRatingPage({super.key});

  @override
  _DriverRatingPageState createState() => _DriverRatingPageState();
}

class _DriverRatingPageState extends State<DriverRatingPage> {
  List<dynamic> _driverData = [];
  String _driverRating = "";
  bool _alertSent = false;

  @override
  void initState() {
    super.initState();
    fetchDriverData();
  }

  Future<void> fetchDriverData() async {
    try {
      final response = await http.get(Uri.parse('$endpoint_1_home/get-latest-readings'));

      if (response.statusCode == 200) {
        print("Response: ${response.body}");  // Add this line for debugging
        setState(() {
          _driverData = jsonDecode(response.body);
          _driverRating = calculateDriverRating(_driverData);
          if (double.parse(_driverRating) < 2.0) {
            sendAlert();
          }
        });
      } else {
        throw Exception('Failed to load driver data');
      }
    } catch (e) {
      print("Error: $e");  // Log any exception
    }
  }

  String calculateDriverRating(List<dynamic> data) {
    // Simple rating logic based on X, Y, Z coordinates
    double totalScore = 0;
    for (var reading in data) {
      double x = reading['x'];
      double y = reading['y'];
      double z = reading['z'];

      totalScore += (x.abs() + y.abs() + z.abs()) / 3;
    }

    return (totalScore / data.length).toStringAsFixed(2); // Average score
  }

  Future<void> sendAlert() async {
    final response = await http.post(
      Uri.parse('$endpoint_1_home/send-alert'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{
        'message': 'Driver is performing poorly!',
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _alertSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Rating'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _driverData.isEmpty
                ? const CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: _driverData.length,
                itemBuilder: (context, index) {
                  var reading = _driverData[index];
                  return ListTile(
                    title: Text('Reading ${index + 1}'),
                    subtitle: Text('X: ${reading['x']}, Y: ${reading['y']}, Z: ${reading['z']}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text('Driver Rating: $_driverRating', style: const TextStyle(fontSize: 24)),
            _alertSent
                ? const Text('Alert Sent!', style: TextStyle(color: Colors.red, fontSize: 20))
                : Container(),
          ],
        ),
      ),
    );
  }
}