import 'package:flutter/material.dart';
import 'package:exploration_project/themes/dark_purple_theme.dart';

class Instructions extends StatelessWidget {
  const Instructions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AveaThemes.current();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("How It Works"),
        backgroundColor: theme.primarySwatch,
      ),
      backgroundColor: theme.backgroundColor,
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "🤝 How It Works",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textColor),
              ),
              const SizedBox(height: 12),
              Text(
                "Choose Your Path",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "• One-on-One Accountability Partner\n"
                "• Mastermind Group Collaboration",
                style: TextStyle(fontSize: 15, color: theme.textColor),
              ),
              const SizedBox(height: 16),

              Divider(color: theme.primarySwatch, thickness: 1),
              const SizedBox(height: 16),

              Text(
                "🗂 Forum-Based Matching",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "• Browse posted goals or publish your own\n"
                "• Click a goal to view the user's profile\n"
                "• Connect and schedule a time to talk and exchange contact information",
                style: TextStyle(fontSize: 15, color: theme.textColor),
              ),
              const SizedBox(height: 16),

              Divider(color: theme.primarySwatch, thickness: 1),
              const SizedBox(height: 16),

              Text(
                "🧭 Archetype Daily Guidance",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "Each user receives one concise Archetype Daily Guidance message per day, automatically delivered through the app.",
                style: TextStyle(fontSize: 15, color: theme.textColor, height: 1.5),
              ),
              const SizedBox(height: 12),
              
              Text(
                "✨ What Are Archetype Daily Guidance Messages?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "Short, original guidance statements designed to:\n"
                "• Reduce resistance\n"
                "• Reinforce consistency\n"
                "• Support clarity and momentum\n"
                "• Match your preferred motivational tone",
                style: TextStyle(fontSize: 15, color: theme.textColor),
              ),
              const SizedBox(height: 12),

              Text(
                "🎭 Choose Your Guidance Archetype",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "• Boardroom CEO – Clear, strategic, results-focused\n"
                "• Calm Monk – Peaceful, centered, disciplined\n"
                "• Champion Coach – Motivating, confident, empowering\n"
                "• Drill Sergeant – Direct, urgent, no-excuses\n"
                "• Gentle Guide Bestie – Supportive, patient, low pressure\n"
                "• Grandmaster of Do Nothing – Stillness is power\n"
                "• Higher Self – Higher Consciousness Companion\n"
                "• Inner Alchemist – Abundant, grounded, magnetic\n"
                "• Mindful Millionaire – Prosperous, intentional, composed\n"
                "• Observational Comedian – Light, honest, disarming\n"
                "• Stoic Mentor – Calm, grounded, steady perspective\n"
                "• The Steward – Responsible, reliable, nurturing\n"
                "• The Voice of Enough – Reassuring, validating, freeing",
                style: TextStyle(fontSize: 14, color: theme.textColor, height: 1.6),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardLighterBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.primarySwatch.withOpacity(0.3)),
                ),
                child: Text(
                  "You may update your archetype preference at any time.\n\n"
                  "Guidance messages are general and supportive, not goal-specific or instructional.\n\n"
                  "All sent and received messages automatically delete after 7 days to encourage forward momentum, daily progress, and fresh, meaningful connection rather than letting conversations grow stale.",
                  style: TextStyle(fontSize: 14, color: theme.textColor, fontStyle: FontStyle.italic, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),

              Divider(color: theme.primarySwatch, thickness: 1),
              const SizedBox(height: 16),

              Text(
                "💬 Messaging",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "• Free 7-Day Trial includes:\n"
                "  - 3 outgoing messages (150 characters max)\n"
                "  - Daily Archetype Guidance messages\n\n"
                "• \$4.99 for 6 months includes:\n"
                "  - 10 outgoing messages\n"
                "  - Daily Archetype Guidance messages\n\n"
                "• Unlimited incoming messages",
                style: TextStyle(fontSize: 15, color: theme.textColor, height: 1.6),
              ),
              const SizedBox(height: 12),
              
              Text(
                "Important Messaging Guidelines",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "• Messages are for scheduling and exchanging contact information only\n"
                "• Not intended for full conversations or coaching\n"
                "• Choose your preferred platform: WhatsApp, Zoom, Skype, Teams, phone, or email\n"
                "• Audio or video calls are encouraged for deeper connection",
                style: TextStyle(fontSize: 15, color: theme.textColor, height: 1.5),
              ),
              const SizedBox(height: 16),

              Divider(color: theme.primarySwatch, thickness: 1),
              const SizedBox(height: 16),

              Text(
                "📝 Getting Started",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor),
              ),
              const SizedBox(height: 12),
              
              Text(
                "1. Registration & Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "• Create your profile: first name, time zone\n"
                "• Optional: gender, age, profession, hobbies\n"
                "• Set availability using the calendar\n"
                "• Select your Archetype Daily Guidance preference\n"
                "• Access via Welcome Screen or Menu (top right)",
                style: TextStyle(fontSize: 15, color: theme.textColor, height: 1.5),
              ),
              const SizedBox(height: 12),

              Text(
                "2. Forum: Post or Search",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "• Post up to 2 goal topics (visible for 90 days)\n"
                "• Delete anytime from your profile\n"
                "• Search by keyword to find aligned partners\n"
                "• Partner for mutual benefit—or simply to support someone's journey",
                style: TextStyle(fontSize: 15, color: theme.textColor, height: 1.5),
              ),
              const SizedBox(height: 12),

              Text(
                "3. Scheduling",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "• Click a goal to view the author's profile\n"
                "• Coordinate calendars to set a meeting time\n"
                "• Send a short message to initiate contact and exchange details",
                style: TextStyle(fontSize: 15, color: theme.textColor, height: 1.5),
              ),
              const SizedBox(height: 16),

              Divider(color: theme.primarySwatch, thickness: 1),
              const SizedBox(height: 16),

              Text(
                "🎯 Apply the Formula",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "Once connected, create 2–3 SMART accountability statements together.",
                style: TextStyle(fontSize: 15, color: theme.textColor),
              ),
              const SizedBox(height: 12),
              
              Text(
                "S.M.A.R.T. Goals",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "• Specific\n"
                "• Measurable\n"
                "• Achievable\n"
                "• Relevant (connected to your deeper purpose)\n"
                "• Time-bound",
                style: TextStyle(fontSize: 15, color: theme.textColor, height: 1.5),
              ),
              const SizedBox(height: 12),
              
              Text(
                "Example",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primarySwatch.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.primarySwatch.withOpacity(0.3)),
                ),
                child: Text(
                  '"I am writing and recording an orchestral pop song, having it produced and published within six months to build a social presence, monetize, and raise the collective vibration."',
                  style: TextStyle(fontSize: 15, color: theme.textColor, fontStyle: FontStyle.italic, height: 1.5),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "These statements become your shared agreement. Weekly check-ins and daily archetype guidance reinforce momentum.",
                style: TextStyle(fontSize: 15, color: theme.textColor, height: 1.5),
              ),
              const SizedBox(height: 16),

              Divider(color: theme.primarySwatch, thickness: 1),
              const SizedBox(height: 16),

              Text(
                "💡 The Power of Consistency",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "Regular conversations—rooted in harmony—are the keystone to a vibrant, successful life.\n\n"
                "Through shared accountability + daily guidance, you'll:\n"
                "• Stay focused\n"
                "• Reframe resistance\n"
                "• Build confidence through aligned action",
                style: TextStyle(fontSize: 15, color: theme.textColor, height: 1.5),
              ),
              const SizedBox(height: 16),

              Divider(color: theme.primarySwatch, thickness: 1),
              const SizedBox(height: 16),

              Text(
                "🚦 Rules & Respect",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "• No explicit, violent, or spam content\n"
                "• No business solicitation or self-promotion\n"
                "• No private or confidential information beyond contact details\n"
                "• Forum is for goal statements only\n"
                "• No advice threads or discussions in forum posts",
                style: TextStyle(fontSize: 15, color: theme.textColor, height: 1.5),
              ),
              const SizedBox(height: 16),

              Divider(color: theme.primarySwatch, thickness: 1),
              const SizedBox(height: 16),

              Text(
                "🔗 Need Help Finding a Partner?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "Connect with Avea—Expert Accountability Partner, Life Coach & Psychic\n\n"
                "📧 Email: amylwilhelm@gmail.com\n"
                "🛍️ Fiverr: fiverr.com/sellers/aqua_wise\n"
                "🔮 Etsy: AskAveaTarot\n"
                "🌐 MysticSense: mysticsense.com/psychics/avea/",
                style: TextStyle(fontSize: 15, color: theme.textColor, height: 1.6),
              ),
              const SizedBox(height: 16),

              Divider(color: theme.primarySwatch, thickness: 1),
              const SizedBox(height: 16),

              Text(
                "💌 Subscription Options",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Text(
                "• Free 7-Day Trial\n"
                "  - 3 outgoing messages\n"
                "  - Daily Archetype Guidance\n\n"
                "• \$4.99 for 6 months\n"
                "  - 10 outgoing messages\n"
                "  - Daily Archetype Guidance\n\n"
                "• Subscriptions are renewable when message limits are reached",
                style: TextStyle(fontSize: 15, color: theme.textColor, height: 1.6),
              ),
              const SizedBox(height: 16),

              Divider(color: theme.primarySwatch, thickness: 1),
              const SizedBox(height: 16),

              Text(
                "🌈 Final Thought",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardLighterBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"The first step is yours to take, but the longest journeys are walked side by side."\n— Z.W.',
                  style: TextStyle(fontSize: 16, color: theme.textColor, fontStyle: FontStyle.italic, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Text(
                  "Enjoy your experience with Ally by AVEA!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: theme.primarySwatch),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        )
      )
    );
  }
}
