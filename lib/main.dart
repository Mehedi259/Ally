import 'package:exploration_project/themes/dark_purple_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';
import 'forum.dart';
import 'menu.dart';
import 'authentication/login.dart';
import 'authentication/onboarding_flow.dart';
import 'bots/bot_seed_data.dart';
import 'service_locator.dart';
import 'firebase/firebase_message_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Seed bot data to Firestore on first run (no-op if already seeded)
    await BotSeedData.seedToFirestoreIfEmpty();
    
    // Delete messages older than 7 days on app startup
    try {
      final messageService = ServiceLocator.messageService;
      if (messageService is FirebaseMessageService) {
        await messageService.deleteOldMessages();
      }
    } catch (e) {
      print('Error deleting old messages: $e');
    }
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Continue anyway - we'll show an error in the UI
  }
  print('Initializing LocalNotificationsService in main()...');
  await ServiceLocator.localNotificationsService.init();
  print('LocalNotificationsService initialization call in main() completed.');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Ally by Avea",
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: AveaThemes.current().themeData,
      home: StreamBuilder(
        stream: ServiceLocator.authService.authStateChanges,
        builder: (context, snapshot) {
          // Show error if there's a Firebase initialization issue
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Firebase Error',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Show loading screen while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // If user is signed in, check if they've completed onboarding
          if (snapshot.hasData) {
            final user = snapshot.data;
            
            // Additional safety check for user data
            if (user?.uid == null) {
              print('WARNING: User data is incomplete, redirecting to login');
              return const LoginScreen();
            }
            
            // Check profile service for onboarding status
            return FutureBuilder(
              future: ServiceLocator.profileService.getUserProfile(
                'dummy_token',
                user!.uid,
              ),
              builder: (context, profileSnapshot) {
                // Show loading while fetching profile
                if (profileSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                // Handle profile loading errors
                if (profileSnapshot.hasError) {
                  print('ERROR: Failed to load profile: ${profileSnapshot.error}');
                  // Show error screen with retry option
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text('Unable to load your profile'),
                          SizedBox(height: 8),
                          Text('This might be a network issue'),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Force a rebuild to retry
                              (context as Element).markNeedsBuild();
                            },
                            child: Text('Retry'),
                          ),
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              // Force new onboarding as fallback
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const OnboardingFlow()),
                                (route) => false,
                              );
                            },
                            child: Text('Start Over'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Check if profile is null, empty, or not onboarded
                final profile = profileSnapshot.data;
                
                // Debug logging
                print('Profile check: profile=${profile?.name}, onboarded=${profile?.onboarded}');
                
                if (profile == null || !profile.onboarded) {
                  return const OnboardingFlow();
                }
                
                return const AveaAppHomepage();
              },
            );
          }
          
          // Otherwise show login screen
          return const LoginScreen();
        },
      ),
    );
  }
}


class AveaAppHomepage extends StatefulWidget {
  const AveaAppHomepage({super.key});

  @override
  State<AveaAppHomepage> createState() => _AveaAppHomepageState();
}

class _AveaAppHomepageState extends State<AveaAppHomepage> {
  @override
  void initState() {
    super.initState();
    _rescheduleBotIfNeeded();
  }

  Future<void> _rescheduleBotIfNeeded() async {
    try {
      final user = ServiceLocator.authService.currentUser;
      if (user == null) return;
      final profile = await ServiceLocator.profileService.getUserProfile('dummy_token', user.uid);
      if (profile == null) return;
      // Support both multi-select and legacy single archetype
      final archetypeIds = profile.selectedArchetypes.isNotEmpty
          ? profile.selectedArchetypes
          : (profile.selectedArchetype != null ? [profile.selectedArchetype!] : []);
      if (archetypeIds.isEmpty) return;
      final archetype = await ServiceLocator.botService.getArchetype(archetypeIds.first);
      if (archetype == null) return;
      await ServiceLocator.botService.activateBot(profile, archetype);
    } catch (e) {
      print('Error rescheduling bot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Color.fromARGB(255, 120, 80, 180),
                  Color.fromARGB(255, 160, 126, 219),
                ],
            ),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 160, 126, 219)
      ),
      body: const Forum(),
      drawer: const AppMenu(),
    );
  }
}
