import 'package:flutter/material.dart';
import 'package:vuhacathon/setting.dart'; // For API requests
import 'fall_alert_page.dart'; // Import the Fall Alert Page
import 'driver_rating_page.dart'; // Import the Driver Rating Page
import 'driver_rating_graph_page.dart'; // Import the Driver Rating Graph Page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IoT App UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: const StyledHomeScreen(),
    );
  }
}

class StyledHomeScreen extends StatefulWidget {
  const StyledHomeScreen({super.key});

  @override
  _StyledHomeScreenState createState() => _StyledHomeScreenState();
}

class _StyledHomeScreenState extends State<StyledHomeScreen> {
  int _selectedIndex = 0;

  // Handle bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget getPage(int index) {
      switch (index) {
        case 0:
          return const DriverRatingPage();
        case 1:
          return const FallAlertPage();
        case 2:
          return const DriverRatingGraphPage(); // Add the graph page here
        case 3:
          return const SettingsPage();
        default:
          return const DriverRatingPage();
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text('<system name >', style: TextStyle(color: Colors.black)),
      ),
      body: getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Driver Rating',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Fall Alert',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Rating Graph', // New graph label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'dart:convert'; // For JSON handling
// import 'package:http/http.dart' as http;
// import 'package:vuhacathon/setting.dart'; // For API requests
// import 'fall_alert_page.dart'; // Import the Fall Alert Page
// import 'driver_rating_page.dart'; // Import the Driver Rating Page
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'IoT App UI',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Poppins',
//       ),
//       home: StyledHomeScreen(),
//     );
//   }
// }
//
// class StyledHomeScreen extends StatefulWidget {
//   @override
//   _StyledHomeScreenState createState() => _StyledHomeScreenState();
// }
//
// class _StyledHomeScreenState extends State<StyledHomeScreen> {
//   int _selectedIndex = 0;
//
//   // Handle bottom navigation bar item taps
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Widget _getPage(int index) {
//       switch (index) {
//         case 0:
//           return DriverRatingPage();
//         case 1:
//           return FallAlertPage();
//         case 2:
//           return SettingsPage();
//         default:
//           return DriverRatingPage();
//       }
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.lightGreenAccent,
//         elevation: 0,
//         title: Text('Dashboard', style: TextStyle(color: Colors.black)),
//       ),
//       body: _getPage(_selectedIndex),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.lightGreenAccent,
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.history),
//             label: 'Driver Rating',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.warning),
//             label: 'Fall Alert',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.orange,
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
//
