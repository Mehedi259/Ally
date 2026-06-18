import 'package:exploration_project/welcome.dart';
import 'package:exploration_project/messaging/messages_screen.dart';
import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'instructions.dart';
import 'service_locator.dart';
import 'authentication/auth_service.dart';

class AppMenu extends StatelessWidget {
  final Function(int) onNavigate;

  const AppMenu({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text("Welcome"),
            leading: const Icon(Icons.interpreter_mode),
            onTap: () {
              onNavigate(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Instructions"),
            leading: const Icon(Icons.kayaking),
            onTap: () {
              onNavigate(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Forum"),
            leading: const Icon(Icons.forum),
            onTap: () {
              onNavigate(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Messages"),
            leading: const Icon(Icons.message),
            onTap: () {
              onNavigate(3);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("Edit Profile"),
            leading: Icon(Icons.edit_note),
            onTap: () {
              onNavigate(4);
              Navigator.pop(context);
            },
          ),
          const ListTile(
            title: const Text("My Professional Links"),
            leading: const Icon(Icons.business),
          ),
          ListTile(
            title: const Text("Logout"),
            leading: const Icon(Icons.logout),
            onTap: () async {
              try {
                await ServiceLocator.authService.signOut();
                // Navigation is handled automatically by StreamBuilder in main.dart
                // Close the drawer and pop all routes to return to root (login screen)
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              } on AuthException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
