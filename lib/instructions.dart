import 'package:flutter/material.dart';
import 'package:exploration_project/main.dart';
import 'package:url_launcher/url_launcher.dart';

class Instructions extends StatelessWidget {
  const Instructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with Background Image
              Container(
                margin: const EdgeInsets.only(top: 60, bottom: 12),
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/instruction banner.jpeg',
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () =>
                              appScaffoldKey.currentState?.openDrawer(),
                        ),
                        const Expanded(
                          child: Text(
                            'Instructions',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      icon: Icons.psychology_outlined,
                      title: 'How It Works',
                      subtitle: 'Choose your path:',
                      items: [
                        'One-on-One Accountability Partner',
                        'Mastermind Group Collaboration',
                        'Forum-Based Matching',
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.people_outline,
                      title: 'Forum-Based Matching',
                      items: [
                        'Browse posted goals or publish your own',
                        'Click a goal to view the user\'s profile',
                        'Connect and schedule a time to talk and exchange contact information',
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.compass_calibration_outlined,
                      title: 'Archetype Daily Guidance',
                      subtitle: 'Each user receives one concise Archetype Daily Guidance message per day, automatically delivered through the app.',
                      customContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'What Are Archetype Daily Guidance Messages?',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Short, original guidance statements designed to:',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          _buildListItems([
                            'Reduce resistance',
                            'Reinforce consistency',
                            'Support clarity and momentum',
                            'Match your preferred motivational tone',
                          ]),
                          const SizedBox(height: 16),
                          const Text(
                            'Choose Your Guidance Archetype',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildListItems([
                            'Boardroom CEO – Clear, strategic, results-focused',
                            'Calm Monk – Peaceful, centered, disciplined',
                            'Champion Coach – Motivating, confident, empowering',
                            'Drill Sergeant – Direct, urgent, no-excuses',
                            'Gentle Guide Bestie – Supportive, patient, low pressure',
                            'Grandmaster of Do Nothing - Stillness is power',
                            'Higher Self – Higher Consciousness Companion',
                            'Inner Alchemist – Abundant, grounded, magnetic',
                            'Mindful Millionaire – Prosperous, intentional, composed',
                            'Observational Comedian – Light, honest, disarming',
                            'Stoic Mentor – Calm, grounded, steady perspective',
                            'The Steward – Responsible, reliable, nurturing',
                            'The Voice of Enough – Reassuring, validating, freeing',
                          ]),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Text(
                              'You may update your archetype preference at any time. Guidance messages are general and supportive, not goal-specific or instructional.',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.chat_bubble_outline,
                      title: 'Messaging',
                      customContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'Free 7-Day Trial includes:',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          _buildListItems([
                            '3 outgoing messages (150 characters max)',
                            'Daily Archetype Guidance messages',
                          ]),
                          const SizedBox(height: 12),
                          const Text(
                            '\$4.99 for 6 months includes:',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          _buildListItems([
                            '10 outgoing messages',
                            'Daily Archetype Guidance messages',
                            'Unlimited incoming messages',
                          ]),
                          const SizedBox(height: 12),
                          const Text(
                            'All sent and received messages automatically delete after 7 days to encourage forward momentum, daily progress, and fresh, meaningful connection rather than letting conversations grow stale.',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Important Messaging Guidelines',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          _buildListItems([
                            'Messages are for scheduling and exchanging contact information only',
                            'Not intended for full conversations or coaching',
                            'Choose your preferred platform: WhatsApp, Zoom, Skype, Teams, phone, or email',
                            'Audio or video calls are encouraged for deeper connection',
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.flag_outlined,
                      title: 'Getting Started',
                      customContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text('1. Registration & Profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          _buildListItems([
                            'Create your profile: first name, time zone',
                            'Optional: gender, age, profession, hobbies',
                            'Set availability using the calendar',
                            'Select your Archetype, Daily Guidance preference, and delivery schedule. Guidance statements are sent daily, refreshed automatically, and cleared after 3 days to support forward momentum.',
                          ]),
                          const SizedBox(height: 16),
                          const Text('2. Forum: Post or Search', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          _buildListItems([
                            'Post up to 1 Goal Statement (visible for 90 days)',
                            'Delete anytime from your profile',
                            'Search by keyword to find aligned partners',
                            'Partner for mutual benefit—or simply to support someone\'s journey',
                          ]),
                          const SizedBox(height: 16),
                          const Text('3. Scheduling', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          _buildListItems([
                            'Click a goal to view the author\'s profile',
                            'Coordinate calendars to set a meeting time',
                            'Send a short message to initiate contact and exchange contact details and begin to connect off the app.',
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.check_circle_outline,
                      title: 'Apply the Formula',
                      subtitle: 'Once connected, create 2–3 SMART accountability statements together.',
                      customContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text('S.M.A.R.T. Goals', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          _buildListItems(['Specific', 'Measurable', 'Achievable', 'Relevant (connected to your deeper purpose)', 'Time-bound']),
                          const SizedBox(height: 12),
                          const Text('Example', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Text(
                              '“I am writing and recording orchestral pop song, having it produced and published within six months to build a social presence, monetize, and raise the collective vibration.”',
                              style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'These statements become your shared agreement. Weekly check-ins and daily archetype guidance reinforce momentum.',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.bolt_outlined,
                      title: 'The Power of Consistency',
                      subtitle: 'Regular conversations—rooted in harmony—are the keystone to a vibrant, successful life.',
                      customContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text('Through shared accountability + daily guidance, you\'ll:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 8),
                          _buildListItems(['Stay focused', 'Reframe resistance', 'Build confidence through aligned action']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.shield_outlined,
                      title: 'Rules & Respect',
                      items: [
                        'No explicit, violent, or spam content',
                        'No business solicitation or self-promotion',
                        'No private or confidential information beyond contact details',
                        'Forum is for goal statements only',
                        'No advice threads or discussions in forum posts',
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.help_outline,
                      title: 'Need Help Finding a Partner?',
                      customContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text('Connect with Avea Accountability Partner, Life Coach & Psychic:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () async {
                              final url = Uri.parse('https://www.aveaexperience.com');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: const Text(
                              'www.aveaexperience.com',
                              style: TextStyle(
                                color: Color(0xFF00CED1),
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF00CED1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.subscriptions_outlined,
                      title: 'Subscription Options',
                      customContent: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text('Free 7-Day Trial', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          _buildListItems(['3 outgoing messages', 'Daily Archetype Guidance']),
                          const SizedBox(height: 12),
                          const Text('\$4.99 for 6 months', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          _buildListItems(['10 outgoing messages', 'Daily Archetype Guidance']),
                          const SizedBox(height: 12),
                          const Text('Subscriptions are renewable when message limits are reached', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: const [
                          Text(
                            '“The first step is yours to take, but the longest journeys are walked side by side.”',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '— Z.W.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Enjoy your experience with Ally by AVEA!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItems(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map(
        (item) => Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '• ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    String? subtitle,
    List<String>? items,
    Widget? customContent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 6, right: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF00CED1), // Cyan dot
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                  if (items != null) ...[
                    const SizedBox(height: 8),
                    _buildListItems(items),
                  ],
                  if (customContent != null) customContent,
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
