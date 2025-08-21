// lib/screens/home/widgets/menu_drawer.dart
import 'package:flutter/material.dart';
import 'package:smart_notes/screens/about/about_screen.dart';
import 'package:smart_notes/screens/archive/archive_screen.dart';
import 'package:smart_notes/screens/deleted/deleted_screen.dart';
import 'package:smart_notes/screens/reminders/reminder_screen.dart';
import 'package:smart_notes/screens/settings/settings_screen.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current theme's color scheme
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      // The drawer itself will correctly use the theme's surface color.
      // We don't need to set a color here.
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              // *** THIS IS THE FIX ***
              // Use the primary color from the current theme.
              // This will now update automatically when you change the theme in settings.
              color: colorScheme.primaryContainer,
            ),
            child: Text(
              'Smart Notes',
              style: TextStyle(
                // Use the color designed to be ON TOP of the primary color.
                // This ensures text is readable (e.g., white on a dark primary).
                color: colorScheme.onPrimaryContainer,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('Notes'),
            onTap: () => Navigator.pop(context), // Just closes the drawer
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Reminders'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReminderScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Archive'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ArchiveScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Deleted'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeletedScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
