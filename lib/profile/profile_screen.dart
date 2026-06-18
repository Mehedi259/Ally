import 'package:flutter/material.dart';
import 'package:exploration_project/themes/dark_purple_theme.dart';
import 'package:exploration_project/edit_profile.dart';
import 'package:exploration_project/service_locator.dart';
import 'package:exploration_project/profile/profile_service.dart';
import 'package:exploration_project/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = ServiceLocator.authService.currentUser;
      if (user != null) {
        final profile = await ServiceLocator.profileService.getUserProfile(
          'token',
          user.uid,
        );
        if (mounted) {
          setState(() {
            _profile = profile;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'A';
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length > 1) {
      return '${parts[0][0].toUpperCase()}${parts[1][0].toUpperCase()}';
    }
    return parts[0][0].toUpperCase();
  }

  Widget _buildNeonHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1A),
        border: Border.all(
          color: const Color(0xFF00CED1).withValues(alpha: 0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CED1).withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFF00CED1).withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors
                  .black, // Makes it look cut out if the background was bright, but here we want white
            ),
          ),
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Positioned(
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF00CED1), size: 28),
              onPressed: () => appScaffoldKey.currentState?.openDrawer(),
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFF00CED1),
                size: 28,
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfile()),
                );
                _loadProfile(); // Reload if changes were made
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarAndInfo() {
    final initials = _getInitials(_profile?.name ?? 'Ally User');
    final username = _profile?.email.split('@').first ?? 'user';
    final tagline = _profile?.profession?.isNotEmpty == true
        ? _profile!.profession!
        : 'Growth. Discipline. Impact.';

    return Column(
      children: [
        // Glowing Text Avatar
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              initials,
              style: TextStyle(
                fontSize: 90,
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = const Color(0xFF00CED1),
                shadows: [
                  BoxShadow(
                    color: const Color(0xFF00CED1).withValues(alpha: 0.8),
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            Text(
              initials,
              style: TextStyle(
                fontSize: 90,
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _profile?.name ?? 'Ally User',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@$username',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF00CED1),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tagline,
          style: const TextStyle(fontSize: 14, color: Color(0xFFBAA7D8)),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: const Color(0xFF8B4C9E), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(Icons.track_changes, 'Goals', '12'),
          _buildDivider(),
          _buildStatItem(Icons.people_outline, 'Connections', '48'),
          _buildDivider(),
          _buildStatItem(Icons.message_outlined, 'Messages', '27'),
          _buildDivider(),
          _buildStatItem(Icons.calendar_month_outlined, 'Meetings', '9'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: const Color(0xFF8B4C9E).withValues(alpha: 0.5),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF00CED1), size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF00CED1), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget content,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF8B4C9E), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00CED1), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF00CED1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                content,
              ],
            ),
          ),
          if (trailing != null)
            trailing
          else
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white30,
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildAboutMe() {
    final goalStatement =
        _profile?.goalStatement ??
        "I'm here to connect with like-minded people, stay accountable, and keep pushing forward every day.";

    return _buildSection(
      icon: Icons.person_outline,
      title: 'About Me',
      content: Text(
        goalStatement,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildFocusAreas() {
    // Determine focus areas. If empty, provide some defaults.
    final List<String> areas = [];
    if (_profile?.hobbies != null && _profile!.hobbies!.isNotEmpty) {
      areas.addAll(_profile!.hobbies!.split(',').map((e) => e.trim()));
    } else {
      areas.addAll(['Discipline', 'Mindset', 'Health', 'Finance', 'Growth']);
    }

    return _buildSection(
      icon: Icons.adjust,
      title: 'Focus Areas',
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: areas.take(5).map((area) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF8B4C9E).withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              area,
              style: const TextStyle(color: Color(0xFFBAA7D8), fontSize: 12),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccountStatus() {
    return _buildSection(
      icon: Icons.verified_user_outlined,
      title: 'Account Status',
      content: const Text(
        'Free Plan  •  14-Day Trial',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF00CED1)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Upgrade',
          style: TextStyle(
            color: Color(0xFF00CED1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00CED1)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.0,
                colors: [
                  const Color(0xFF00CED1).withValues(alpha: 0.1),
                  Colors.black,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
            child: Column(
              children: [
                _buildNeonHeader(),
                const SizedBox(height: 20),
                _buildAvatarAndInfo(),
                _buildStatsRow(),
                _buildAboutMe(),
                _buildFocusAreas(),
                _buildAccountStatus(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
