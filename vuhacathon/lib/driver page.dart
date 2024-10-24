// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class BikeDriverRatingPage extends StatefulWidget {
//   @override
//   _BikeDriverRatingPageState createState() => _BikeDriverRatingPageState();
// }
//
// class _BikeDriverRatingPageState extends State<BikeDriverRatingPage> {
//   late Map<String, dynamic> driverData = {};
//
//   @override
//   void initState() {
//     super.initState();
//     fetchDriverData();  // Call API to fetch data on load
//   }
//
//   Future<void> fetchDriverData() async {
//     final response = await http.get(Uri.parse('http://http://192.168.1.165:5000/api/get_driver_rating/001'));
//
//     if (response.statusCode == 200) {
//       setState(() {
//         driverData = jsonDecode(response.body);
//       });
//     } else {
//       throw Exception('Failed to load driver data');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black, // Set the background color to black
//       appBar: AppBar(
//         backgroundColor: Colors.lightGreenAccent,
//         elevation: 0,
//         title: Text(
//           'Bike Driver Rating',
//           style: TextStyle(color: Colors.black),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: driverData.isNotEmpty ? buildDriverRating() : Center(child: CircularProgressIndicator()),
//     );
//   }
//
//   Widget buildDriverRating() {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 10),
//           Text(
//             'Bike Driver Performance Metrics',
//             style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.yellowAccent),
//           ),
//           SizedBox(height: 20),
//           Expanded(
//             child: GridView.count(
//               crossAxisCount: 2, // Number of items per row
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//               children: [
//                 buildMetricCard(
//                   title: 'Acceleration',
//                   value: driverData['rating'].toString(), // Example rating from API
//                   weight: '20%',
//                   icon: Icons.speed,
//                   color: Colors.yellow,
//                   backgroundColor: Colors.lightGreenAccent,
//                 ),
//                 // Add more metrics as per your UI requirement
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper method to build a metric card
//   Widget buildMetricCard({
//     required String title,
//     required String value,
//     required String weight,
//     required IconData icon,
//     required Color color,
//     required Color backgroundColor,
//   }) {
//     return Card(
//       color: backgroundColor,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 40, color: color),
//           SizedBox(height: 10),
//           Text(
//             title,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//           ),
//           SizedBox(height: 10),
//           Text(
//             value,
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
//           ),
//           SizedBox(height: 5),
//           Text(
//             'Weight: $weight',
//             style: TextStyle(fontSize: 12, color: Colors.black54),
//           ),
//         ],
//       ),
//     );
//   }
// }