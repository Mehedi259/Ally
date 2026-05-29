import 'package:flutter/material.dart';
import 'package:exploration_project/themes/dark_purple_theme.dart';
import 'package:exploration_project/main.dart';
import 'create_profile.dart';

/// Onboarding flow that walks new users through:
/// 1. Welcome screen
/// 2. Instructions screen  
/// 3. Create profile screen
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _completeOnboarding() {
    // Navigate directly to the forum screen
    if (mounted) {
      // Replace everything with the forum homepage
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const AveaAppHomepage(),
        ),
        (route) => false, // Remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent back button from exiting onboarding
      onWillPop: () async => false,
      child: IndexedStack(
        index: _currentStep,
        children: [
          // Step 1: Welcome
          _WelcomeStep(
            onNext: _nextStep,
            currentStep: _currentStep,
          ),
          
          // Step 2: Instructions
          _InstructionsStep(
            onNext: _nextStep,
            onBack: _previousStep,
            currentStep: _currentStep,
          ),
          
          // Step 3: Create Profile
          CreateProfileScreen(
            onComplete: _completeOnboarding,
            onBack: _previousStep,
            currentStep: _currentStep,
          ),
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  final int currentStep;

  const _WelcomeStep({
    required this.onNext,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
        backgroundColor: AveaThemes.current().primarySwatch,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Container(
            color: AveaThemes.current().primarySwatch,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, top: 2),
                  child: Text(
                    'Step ${currentStep + 1} of 3',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                LinearProgressIndicator(
                  value: (currentStep + 1) / 3,
                  backgroundColor: AveaThemes.current().primarySwatch.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "🌟 Welcome to Ally by Avea!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "\"Take the first step in faith. You don't have to see the whole staircase.\" — Martin Luther King Jr.",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Ally by Avea is your gateway to meaningful progress through Accountability Partnerships and Mastermind Groups. Whether you're launching a dream, building a habit, or pursuing a bold goal, this app connects you with others who share your drive—and helps you stay on track.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
                const Text(
                  "🔑  Why Ally by Avea Works",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Energy fuels creation. When two or more people unite in harmony, their combined thought energy becomes a powerful force for manifestation. Ally by Avea is your Alliance Portal—a space to connect, commit, and co-create with others who elevate your momentum.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
                const Text(
                  "⚡ The Creation Formula",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Desire + Will (Aligned Action) > Resistance = Fulfillment When desire and will outweigh resistance, goals become reality. Accountability minimizes resistance by adding positive pressure and shared commitment.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
                const Text(
                  "🧠 The Mastermind Principle",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Inspired by Napoleon Hill:\n\n\"A coordination of knowledge and effort, in a spirit of harmony, between two or more people, for the attainment of a definite purpose.\"",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AveaThemes.current().primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onNext,
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructionsStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final int currentStep;

  const _InstructionsStep({
    required this.onNext,
    required this.onBack,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Instructions"),
        backgroundColor: AveaThemes.current().primarySwatch,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Container(
            color: AveaThemes.current().primarySwatch,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, top: 2),
                  child: Text(
                    'Step ${currentStep + 1} of 3',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                LinearProgressIndicator(
                  value: (currentStep + 1) / 3,
                  backgroundColor: AveaThemes.current().primarySwatch.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "🤝 How It Works",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Choose your path:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                "•\tOne-on-One Accountability Partner\n"
                "•\tMastermind Group Collaboration",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                "🗂 Forum-Based Matching",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "•\tBrowse posted goals or publish your own\n"
                "•\tClick a goal to view the user's profile\n"
                "•\tConnect and schedule a time to talk",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                "💬 Messaging",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "•\tFree 14-Day Trial includes 3 messages (150 characters max)\n"
                "•\t\$5.99 for 6 months includes 10 messages\n"
                "•\tUnlimited incoming messages\n"
                "•\tMessages are for scheduling only—not full conversations\n"
                "•\tChoose your preferred platform: WhatsApp, Zoom, Skype, Teams, phone, or email\n"
                "•\tAudio or video chats are encouraged for deeper connection",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                "📝 Getting Started",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                "1. Registration & Profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "•\tCreate your profile: first name, time zone, optional details (gender, age, profession, hobbies)\n"
                "•\tSet your availability using the calendar\n"
                "•\tAccess via Welcome Screen or Menu (top right corner)\n  ",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                "2. Forum: Post or Search",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "•\tPost up to 2 goal topics (visible for 90 days)\n"
                "•\tDelete anytime from your profile\n"
                "•\tSearch by keyword to find aligned partners\n"
                "•\tPartner for mutual benefit or simply to support someone's journey\n",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                "3. Scheduling",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "•\tClick a goal to view the author's profile\n"
                "•\tCoordinate calendars to set a meeting time\n"
                "•\tSend a short message to initiate contact\n",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AveaThemes.current().primarySwatch,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onNext,
                  child: const Text(
                    "Create Your Profile",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
