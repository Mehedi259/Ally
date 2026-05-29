import 'package:exploration_project/welcome.dart';
import 'package:exploration_project/messaging/messages_screen.dart';
import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'instructions.dart';
import 'service_locator.dart';
import 'authentication/auth_service.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({super.key});

  @override
  Widget build(BuildContext context){
    return Drawer(
      child: ListView(
        children: [
            ListTile(
              title: const Text("Welcome"),
              leading: const Icon(Icons.interpreter_mode),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => const Welcome(),
                  ),
                );
              }
            ),
            ListTile(
              title: const Text("Instructions"),
              leading: const Icon(Icons.kayaking),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => const Instructions(),
                  ),
                );
              }
            ),
            ListTile(
              title: const Text("Forum"),
              leading: const Icon(Icons.forum),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Messages"),
              leading: const Icon(Icons.message),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => const MessagesScreen()),
                );
              }
            ),
            ListTile(
              title:  Text("Edit Profile"),
              leading:  Icon(Icons.edit_note),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => const EditProfile(),
                  ),
                );
              }
            ),
            const ListTile(
              title: const Text("My Professional Links"),
              leading: const Icon(Icons.business)
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
