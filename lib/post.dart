import 'package:flutter/material.dart';
import 'service_locator.dart';
import 'view_profile.dart';

class Post2 extends StatelessWidget {
  final String title;
  final String content;
  final DateTime createdAt;
  final Color textColor;
  final String userId;

  Post2({required this.title, required this.content, required this.createdAt, required this.userId, this.textColor = Colors.black});

  @override
  Widget build(BuildContext context){
      String currentUserId = '';
      try { currentUserId = ServiceLocator.getLoggedInUserId(); } catch (_) {}

      return Row(
       children: [
        Expanded(child: TextButton(style: TextButton.styleFrom(alignment: Alignment.centerLeft), child: Text(this.content, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text("Post Details"),
                  backgroundColor: const Color.fromARGB(255, 160, 126, 219),
                ),
                body: ViewProfile(currentUserId: currentUserId, userId: userId),
              ),
            ),
          );
        },
        )),
       ],
      );
  }


}