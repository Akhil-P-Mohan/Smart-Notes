import 'package:flutter/material.dart';
import 'package:smart_notes/screens/about/about_screen.dart';
import 'package:smart_notes/screens/settings/settings_screen.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              'Smart Notes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('Notes'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Reminders'),
            onTap: () {
              // TODO: Navigate to Reminders page
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Archive'),
            onTap: () {
              // TODO: Navigate to Archive page
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Deleted'),
            onTap: () {
              // TODO: Navigate to Deleted page
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()));
            },
          ),
        ],
      ),
    );
  }
}
