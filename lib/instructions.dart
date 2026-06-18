import 'package:flutter/material.dart';
import 'package:exploration_project/main.dart';

class Instructions extends StatelessWidget {
  const Instructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
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
            Expanded(
              child: SingleChildScrollView(
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
                        'Connect and schedule a time to talk',
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.chat_bubble_outline,
                      title: 'Messaging',
                      items: [
                        'Free 14-Day Trial includes 3 messages (150 characters)',
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.verified_user_outlined,
                      title: 'Safety & Respect',
                      items: [
                        'Be kind, respectful, and encouraging',
                        'No spam, promotions, or inappropriate content',
                        'Report any issues to our support team',
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      icon: Icons.lock_outline,
                      title: 'Privacy',
                      items: ['Your conversations are private and secure'],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    String? subtitle,
    required List<String> items,
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
                  const SizedBox(height: 8),
                  ...items.map(
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
