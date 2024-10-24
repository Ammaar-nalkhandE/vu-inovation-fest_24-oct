import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'globals.dart';

class FallAlertPage extends StatefulWidget {
  const FallAlertPage({super.key});

  @override
  _FallAlertPageState createState() => _FallAlertPageState();
}

class _FallAlertPageState extends State<FallAlertPage> {
  bool _accidentOccurred = false;
  bool _alertSent = false;

  @override
  void initState() {
    super.initState();
    fetchAccidentData();
  }

  Future<void> fetchAccidentData() async {
    try {
      final response = await http.get(Uri.parse('$endpoint_1_home/check-accident'));

      if (response.statusCode == 200) {
        print("Response: ${response.body}");
        setState(() {
          var data = jsonDecode(response.body);
          _accidentOccurred = data['accident'] == 1;
          if (_accidentOccurred) {
            sendAlert();
          }
        });
      } else {
        throw Exception('Failed to load accident data');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> sendAlert() async {
    final response = await http.post(
      Uri.parse('$endpoint_1_home/send-alert'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{
        'message': 'Accident detected! Sending alert to family, ambulance, and nearby users!',
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
        title: const Text('Fall Alert'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _accidentOccurred ? 'Accident Detected!' : 'No Accident Detected',
              style: TextStyle(fontSize: 24, color: _accidentOccurred ? Colors.red : Colors.green),
            ),
            const SizedBox(height: 20),
            _accidentOccurred
                ? const Text('Sending Alert...', style: TextStyle(fontSize: 18, color: Colors.red))
                : const Text('System is monitoring...', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            _alertSent
                ? const Text('Alert Sent!', style: TextStyle(color: Colors.red, fontSize: 20))
                : Container(),
          ],
        ),
      ),
    );
  }
}