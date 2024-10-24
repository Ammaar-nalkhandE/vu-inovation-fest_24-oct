import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:convert'; // For JSON handling
import 'package:http/http.dart' as http;
import 'package:vuhacathon/globals.dart';

class DriverRatingGraphPage extends StatefulWidget {
  const DriverRatingGraphPage({super.key});

  @override
  _DriverRatingGraphPageState createState() => _DriverRatingGraphPageState();
}

class _DriverRatingGraphPageState extends State<DriverRatingGraphPage> {
  List<dynamic> _driverData = [];
  List<charts.Series<DriverRating, String>> _chartData = [];

  @override
  void initState() {
    super.initState();
    fetchDriverData();
  }

  Future<void> fetchDriverData() async {
    try {
      final response = await http.get(Uri.parse('$endpoint_1_home/for-graph'));

      if (response.statusCode == 200) {
        print("Response: ${response.body}");
        setState(() {
          _driverData = jsonDecode(response.body);
          _chartData = _generateChartData();
        });
      } else {
        throw Exception('Failed to load driver data');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Method to calculate mean for each 100, 200, 300 readings
  List<charts.Series<DriverRating, String>> _generateChartData() {
    List<DriverRating> data = [];
    for (int i = 0; i < _driverData.length; i += 100) {
      double totalScore = 0;
      int count = 0;

      for (int j = i; j < i + 100 && j < _driverData.length; j++) {
        double x = _driverData[j]['x'];
        double y = _driverData[j]['y'];
        double z = _driverData[j]['z'];

        totalScore += (x.abs() + y.abs() + z.abs()) / 3;
        count++;
      }

      double meanScore = totalScore / count;
      data.add(DriverRating('Readings ${i + 1}-${i + count}', meanScore));
    }

    return [
      charts.Series<DriverRating, String>(
        id: 'DriverRating',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (DriverRating rating, _) => rating.readingInterval,
        measureFn: (DriverRating rating, _) => rating.rating,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Rating Graph'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _chartData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Expanded(
              child: charts.BarChart(
                _chartData,
                animate: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverRating {
  final String readingInterval;
  final double rating;

  DriverRating(this.readingInterval, this.rating);
}