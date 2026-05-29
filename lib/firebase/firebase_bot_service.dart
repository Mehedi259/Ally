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
    if (p.botDays.isEmpty || p.botTime == null) return;

    // Cancel existing scheduled notifications and future Firestore messages
    await ServiceLocator.localNotificationsService.cancelBotNotifications();
    await ServiceLocator.messageService.cancelFutureBotMessages(p.id);

    // Generate the schedule
    final schedule = _buildSchedule(p, archetype.messages);
    if (schedule.isEmpty) return;

    // Schedule local notifications
    await ServiceLocator.localNotificationsService.scheduleBotNotifications(
      schedule.map((e) => (
        id: e.id,
        scheduledAt: e.scheduledAt,
        title: archetype.displayName,
        body: e.message,
      )).toList(),
    );

    // Write messages to Firestore so they appear in the inbox at delivery time
    final botSenderId = BotSenderHelper.senderIdForArchetype(archetype.id);
    await ServiceLocator.messageService.writeBotMessages(
      botSenderId,
      p.id,
      schedule.map((e) => (
        scheduledAt: e.scheduledAt.toLocal(),
        content: e.message,
      )).toList(),
    );
  }

  @override
  Future<void> deactivateBot(String userId) async {
    await ServiceLocator.localNotificationsService.cancelBotNotifications();
    await ServiceLocator.messageService.cancelFutureBotMessages(userId);
  }

  static const Map<String, String> _timezoneMap = {
    'US/Eastern': 'America/New_York',
    'US/Central': 'America/Chicago',
    'US/Mountain': 'America/Denver',
    'US/Pacific': 'America/Los_Angeles',
    'US/Alaska': 'America/Anchorage',
    'US/Hawaii': 'Pacific/Honolulu',
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
    List<String> messages,
  ) {
    final timeParts = profile.botTime!.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final ianaTimezone = _timezoneMap[profile.timezone] ?? 'America/Los_Angeles';
    final location = tz.getLocation(ianaTimezone);

    final selectedWeekdays = profile.botDays
        .map((day) => _dayToWeekday[day])
        .whereType<int>()
        .toSet();

    final shuffled = List<String>.from(messages)..shuffle(Random());

    final now = tz.TZDateTime.now(location);
    final today = tz.TZDateTime(location, now.year, now.month, now.day);
    var cursor = today.subtract(const Duration(days: 1));
    int count = 0;
    int messageIndex = 0;

    final result = <({int id, tz.TZDateTime scheduledAt, String message})>[];

    while (count < _maxNotifications) {
      cursor = cursor.add(const Duration(days: 1));
      if (!selectedWeekdays.contains(cursor.weekday)) continue;

      final scheduledTime = tz.TZDateTime(
        location, cursor.year, cursor.month, cursor.day, hour, minute,
      );
      if (scheduledTime.isBefore(now)) continue;

      result.add((
        id: _botNotificationBaseId + count,
        scheduledAt: scheduledTime,
        message: shuffled[messageIndex % shuffled.length],
      ));
      messageIndex++;
      count++;
    }

    return result;
  }
}
