import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _locationTrackingEnabled = false;
  String _accountName = "User Account";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Keep the black background
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text(
                'Enable Notifications',
                style: TextStyle(color: Colors.black), // Set text color to green
              ),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text(
                'Enable Location Tracking',
                style: TextStyle(color: Colors.black), // Set text color to green
              ),
              value: _locationTrackingEnabled,
              onChanged: (value) {
                setState(() {
                  _locationTrackingEnabled = value;
                });
              },
            ),
            ListTile(
              title: Text(
                'Account Name: $_accountName',
                style: const TextStyle(color: Colors.black), // Set text color to green
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.black), // Icon color set to green
                onPressed: _showEditAccountDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAccountDialog() {
    TextEditingController controller = TextEditingController(text: _accountName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Account Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Account Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _accountName = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}


