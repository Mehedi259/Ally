import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  final TextAlign headingAlign = TextAlign.center;
  final TextAlign bodyAlign = TextAlign.justify;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background image for full screen including AppBar area
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Welcome bg.png'),
            fit: BoxFit.cover,
            opacity: 1.0,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar with transparent background
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "Welcome",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button width
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
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
                              fontSize: 28, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          Text(
                            "\"Take the first step in faith. You don't have to see the whole staircase.\" — Martin Luther King Jr.",
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: bodyAlign,
                          ),
                          const SizedBox(height: 25),
                          Text(
                            "Ally by Avea is your gateway to meaningful progress through Accountability Partnerships and Mastermind Groups. Whether you're launching a dream, building a habit, or pursuing a bold goal, this app connects you with others who share your drive—and helps you stay on track.",
                            style: const TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: bodyAlign,
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Why Ally by Avea Works",
                            style: TextStyle(
                              fontSize: 26, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),
                          Text(
                            "Energy fuels creation. When two or more people unite in harmony, their combined thought energy becomes a powerful force for manifestation. Ally by Avea is your Alliance Portal—a space to connect, commit, and co-create with others who elevate your momentum.",
                            style: const TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: bodyAlign,
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "The Creation Formula",
                            style: TextStyle(
                              fontSize: 26, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),
                          Text(
                            "Desire + Will (Aligned Action) > Resistance = Fulfillment\n\nWhen desire and will outweigh resistance, goals become reality. Accountability minimizes resistance by adding positive pressure and shared commitment.",
                            style: const TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: bodyAlign,
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "The Mastermind Principle",
                            style: TextStyle(
                              fontSize: 26, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),
                          Text(
                            "Inspired by Napoleon Hill:\n\n\"A coordination of knowledge and effort, in a spirit of harmony, between two or more people, for the attainment of a definite purpose.\"",
                            style: const TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: bodyAlign,
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
            ],
          ),
        ),
      ),
    );
  }
}
