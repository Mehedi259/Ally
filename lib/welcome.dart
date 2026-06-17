import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  final TextAlign headingAlign = TextAlign.center;
  final TextAlign bodyAlign = TextAlign.justify;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
        backgroundColor: const Color.fromARGB(255, 160, 126, 219),
      ),
      body: Container(
        // Background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Welcome bg.png'),
            fit: BoxFit.cover,
            opacity: 0.3, // Make it subtle so text is readable
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome to Ally by Avea!",
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "\"Take the first step in faith. You don't have to see the whole staircase.\" — Martin Luther King Jr.",
                      style: const TextStyle(
                        fontSize: 16, 
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                      textAlign: bodyAlign,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Ally by Avea is your gateway to meaningful progress through Accountability Partnerships and Mastermind Groups. Whether you're launching a dream, building a habit, or pursuing a bold goal, this app connects you with others who share your drive—and helps you stay on track.",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: bodyAlign,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Why Ally by Avea Works",
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Energy fuels creation. When two or more people unite in harmony, their combined thought energy becomes a powerful force for manifestation. Ally by Avea is your Alliance Portal—a space to connect, commit, and co-create with others who elevate your momentum.",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: bodyAlign,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "The Creation Formula",
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Desire + Will (Aligned Action) > Resistance = Fulfillment\n\nWhen desire and will outweigh resistance, goals become reality. Accountability minimizes resistance by adding positive pressure and shared commitment.",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: bodyAlign,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "The Mastermind Principle",
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Inspired by Napoleon Hill:\n\n\"A coordination of knowledge and effort, in a spirit of harmony, between two or more people, for the attainment of a definite purpose.\"",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: bodyAlign,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 160, 126, 219),
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Get Started",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
