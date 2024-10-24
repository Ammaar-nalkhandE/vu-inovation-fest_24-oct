import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(color: Colors.lightGreenAccent),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text(
              'Driving Skills Rating',
              style: TextStyle(color: Colors.lightGreenAccent),
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DrivingSkillsPage()),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Fall Detection Report',
              style: TextStyle(color: Colors.lightGreenAccent),
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FallDetectionPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DrivingSkillsPage extends StatefulWidget {
  const DrivingSkillsPage({super.key});

  @override
  _DrivingSkillsPageState createState() => _DrivingSkillsPageState();
}

class _DrivingSkillsPageState extends State<DrivingSkillsPage> {
  List<DriverRatingData> driverRatings = [];

  @override
  void initState() {
    super.initState();
    fetchDriverRatings();
  }

  Future<void> fetchDriverRatings() async {
    final response = await http.get(Uri.parse('http://192.168.1.165:5000/driver-ratings'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        driverRatings = data
            .map((item) => DriverRatingData(
          date: item['date'],
          rating: item['rating'].toDouble(),
        ))
            .toList();
      });
    } else {
      throw Exception('Failed to load driver ratings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreenAccent,
      appBar: AppBar(
        title: const Text('Driving Skills Rating'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Driving Skills Rating (Out of 5)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: driverRatings
                      .asMap()
                      .entries
                      .map((e) => BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.rating,
                        color: Colors.blue,
                        width: 16,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ))
                      .toList(),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          return Text(driverRatings[index].date);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FallDetectionPage extends StatefulWidget {
  const FallDetectionPage({super.key});

  @override
  _FallDetectionPageState createState() => _FallDetectionPageState();
}

class _FallDetectionPageState extends State<FallDetectionPage> {
  List<FallDetectionData> fallHistory = [];

  @override
  void initState() {
    super.initState();
    fetchFallHistory();
  }

  Future<void> fetchFallHistory() async {
    final response = await http.get(Uri.parse('http://192.168.1.165:5000/fall-detection'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        fallHistory = data.map((item) => FallDetectionData(
          date: item['date'],
          time: item['time'],
          fallDetected: item['fall_detected'],
          chanceOfFall: item['chance_of_fall'],
        )).toList();
      });
    } else {
      throw Exception('Failed to load fall detection data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreenAccent,
      appBar: AppBar(
        title: const Text('Fall Detection Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fall Detection History',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: fallHistory.length,
                itemBuilder: (context, index) {
                  final fall = fallHistory[index];
                  return Card(
                    color: fall.fallDetected ? Colors.redAccent : Colors.greenAccent,
                    child: ListTile(
                      title: Text(
                        'Date: ${fall.date}, Time: ${fall.time}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        fall.fallDetected
                            ? 'Fall Detected'
                            : 'Chance of Fall: ${fall.chanceOfFall}%',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverRatingData {
  final String date;
  final double rating;

  DriverRatingData({required this.date, required this.rating});
}

class FallDetectionData {
  final String date;
  final String time;
  final bool fallDetected;
  final int? chanceOfFall;

  FallDetectionData({
    required this.date,
    required this.time,
    required this.fallDetected,
    this.chanceOfFall,
  });
}
