import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  final TextAlign headingAlign = TextAlign.center;
  final TextAlign bodyAlign = TextAlign.justify;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
        backgroundColor: const Color.fromARGB(255, 160, 126, 219),
      ),
      body: SingleChildScrollView(child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "🌟 Welcome to Ally by Avea!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: headingAlign,
              ),
              SizedBox(height: 20),
              Text(
                "\"Take the first step in faith. You don’t have to see the whole staircase.\" — Martin Luther King Jr.",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: bodyAlign,
              ),
              SizedBox(height: 20),
              Text(
                "Ally by Avea is your gateway to meaningful progress through Accountability Partnerships and Mastermind Groups. Whether you're launching a dream, building a habit, or pursuing a bold goal, this app connects you with others who share your drive—and helps you stay on track.",
                style: TextStyle(fontSize: 16),
                textAlign: bodyAlign,
              ),

              SizedBox(height: 20),
              Text(
                "🔑  Why Ally by Avea Works",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: headingAlign,
              ),
              
              SizedBox(height: 20),
              Text(
                "Energy fuels creation. When two or more people unite in harmony, their combined thought energy becomes a powerful force for manifestation. Ally by Avea is your Alliance Portal—a space to connect, commit, and co-create with others who elevate your momentum.",
                style: TextStyle(fontSize: 16),
                textAlign: bodyAlign,
              ),

              SizedBox(height: 20),
              Text(
                "⚡ The Creation Formula",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 20),
              Text(
                "Desire + Will (Aligned Action) > Resistance = Fulfillment When desire and will outweigh resistance, goals become reality. Accountability minimizes resistance by adding positive pressure and shared commitment.",
                style: TextStyle(fontSize: 16),
                textAlign: bodyAlign,
              ),
              
              
              SizedBox(height: 20),
              Text(
                "🧠 The Mastermind Principle",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: headingAlign,
              ),
              
              SizedBox(height: 20),
              Text(
                "Inspired by Napoleon Hill:\n\n\"A coordination of knowledge and effort, in a spirit of harmony, between two or more people, for the attainment of a definite purpose.\”",
                style: TextStyle(fontSize: 16),
                textAlign: bodyAlign,
              ),


              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Get Started"),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }
}