import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import '/bots/bot_service.dart';
import '/profile/profile_service.dart';
import '/service_locator.dart';

class FirebaseBotService implements IBotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bots';

  @override
  Future<List<BotArchetype>> getAllArchetypes() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => BotArchetype.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching archetypes: $e');
      return [];
    }
  }

  @override
  Future<BotArchetype?> getArchetype(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return BotArchetype.fromJson(doc.data()!);
    } catch (e) {
      print('Error fetching archetype $id: $e');
      return null;
    }
  }

  @override
  Future<void> activateBot(dynamic profile, BotArchetype archetype) async {
    final p = profile as UserProfile;

    print('🤖 activateBot called for user: ${p.id}');
    print('   botDays: ${p.botDays}');
    print('   botTime: ${p.botTime}');

    // Removed the requirement for botDays and botTime to be set
    // since the new logic schedules immediately and then every 72 hours.

    print('   ✅ Bot activation proceeding...');

    // Resolve the full list of selected archetype IDs (prefer multi-select, fall back to legacy single)
    final List<String> archetypeIds = p.selectedArchetypes.isNotEmpty
        ? p.selectedArchetypes
        : (p.selectedArchetype != null
              ? [p.selectedArchetype!]
              : [archetype.id]);

    // Fetch all selected archetypes' messages
    List<String> combinedMessages = [];
    for (final id in archetypeIds) {
      final a = await getArchetype(id);
      if (a != null) {
        combinedMessages.addAll(a.messages);
      }
    }
    // If nothing fetched (edge case), fall back to the provided archetype
    if (combinedMessages.isEmpty) {
      combinedMessages = List<String>.from(archetype.messages);
    }

    // Shuffle the combined message pool to prevent repetition
    combinedMessages.shuffle(Random());

    // Cancel existing scheduled notifications and future Firestore messages
    await ServiceLocator.localNotificationsService.cancelBotNotifications();
    await ServiceLocator.messageService.cancelFutureBotMessages(p.id);

    // Compute 72-hour delay offset based on last activity
    final delayHours = _computeDelayHours(p.lastActivityAt);

    // Generate the schedule with the delay
    final schedule = _buildSchedule(
      p,
      combinedMessages,
      delayHours: delayHours,
    );
    if (schedule.isEmpty) {
      print('   ⚠️ Schedule is empty, no messages will be sent');
      return;
    }

    print('   📅 Generated ${schedule.length} scheduled messages');
    print('   📅 First message at: ${schedule.first.scheduledAt}');
    if (schedule.length > 1) {
      print('   📅 Second message at: ${schedule[1].scheduledAt}');
    }

    // Schedule local notifications
    await ServiceLocator.localNotificationsService.scheduleBotNotifications(
      schedule
          .map(
            (e) => (
              id: e.id,
              scheduledAt: e.scheduledAt,
              title: _buildDisplayName(archetypeIds),
              body: e.message,
            ),
          )
          .toList(),
    );

    // Write messages to Firestore so they appear in the inbox at delivery time
    // Use the primary/first archetype's sender ID (or 'bot_multi' for multi-select)
    final botSenderId = archetypeIds.length == 1
        ? BotSenderHelper.senderIdForArchetype(archetypeIds.first)
        : BotSenderHelper.senderIdForArchetype(archetypeIds.first);
    await ServiceLocator.messageService.writeBotMessages(
      botSenderId,
      p.id,
      schedule
          .map(
            (e) => (scheduledAt: e.scheduledAt.toLocal(), content: e.message),
          )
          .toList(),
    );
  }

  @override
  Future<void> deactivateBot(String userId) async {
    await ServiceLocator.localNotificationsService.cancelBotNotifications();
    await ServiceLocator.messageService.cancelFutureBotMessages(userId);
  }

  // ─────────────────────────── helpers ────────────────────────────────────

  /// Returns a comma-separated display name for one or more archetypes.
  String _buildDisplayName(List<String> archetypeIds) {
    if (archetypeIds.length == 1) {
      return BotSenderHelper.displayNameForSenderId(
            BotSenderHelper.senderIdForArchetype(archetypeIds.first),
          ) ??
          'Your Ally Bot';
    }
    return 'Your Ally Bot';
  }

  /// Computes the hours to delay the first message based on user's last
  /// activity.
  /// NEW LOGIC: First message is immediate (0 delay), subsequent messages
  /// will be scheduled with 72-hour gaps in _buildSchedule.
  int _computeDelayHours(DateTime? lastActivityAt) {
    // Always return 0 so first message comes immediately
    return 0;
  }

  static const Map<String, String> _timezoneMap = {
    'US/Eastern': 'America/New_York',
    'US/Central': 'America/Chicago',
    'US/Mountain': 'America/Denver',
    'US/Pacific': 'America/Los_Angeles',
    'US/Alaska': 'America/Anchorage',
    'US/Hawaii': 'Pacific/Honolulu',
    'Asia/Dhaka': 'Asia/Dhaka', // Bangladesh timezone
  };

  static const Map<String, int> _dayToWeekday = {
    'Monday': DateTime.monday,
    'Tuesday': DateTime.tuesday,
    'Wednesday': DateTime.wednesday,
    'Thursday': DateTime.thursday,
    'Friday': DateTime.friday,
    'Saturday': DateTime.saturday,
    'Sunday': DateTime.sunday,
  };

  static const int _botNotificationBaseId = 1000;
  static const int _maxNotifications = 60;

  List<({int id, tz.TZDateTime scheduledAt, String message})> _buildSchedule(
    UserProfile profile,
    List<String> messages, {
    int delayHours = 0,
  }) {
    final ianaTimezone =
        _timezoneMap[profile.timezone] ??
        profile.timezone ??
        'America/Los_Angeles';
    final location = tz.getLocation(ianaTimezone);

    final now = tz.TZDateTime.now(location);

    final result = <({int id, tz.TZDateTime scheduledAt, String message})>[];
    int messageIndex = 0;

    // First message: schedule immediately (within next few seconds)
    result.add((
      id: _botNotificationBaseId,
      scheduledAt: now.add(const Duration(seconds: 5)), // 5 seconds from now
      message: messages[messageIndex % messages.length],
    ));
    messageIndex++;

    // Subsequent messages: schedule 72 hours apart
    var nextScheduledTime = now.add(const Duration(hours: 72));
    int count = 1;

    while (count < _maxNotifications && messageIndex < messages.length * 10) {
      // Allow message repetition
      result.add((
        id: _botNotificationBaseId + count,
        scheduledAt: nextScheduledTime,
        message: messages[messageIndex % messages.length],
      ));

      messageIndex++;
      count++;
      nextScheduledTime = nextScheduledTime.add(const Duration(hours: 72));
    }

    return result;
  }
}
