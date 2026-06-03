import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() {
  // Initialize timezone data
  tz.initializeTimeZones();
  
  // Your profile data from the logs
  final botTime = '05:18';  // 5:18 AM
  final botDays = ['Thursday', 'Tuesday', 'Wednesday', 'Monday', 'Friday', 'Saturday', 'Sunday'];
  final timezone = 'US/Pacific';  // America/Los_Angeles
  final lastActivityAt = DateTime.parse('2026-06-02T23:16:36.994202Z');
  
  print('═══════════════════════════════════════════════════════════');
  print('🤖 BOT MESSAGE SCHEDULE CHECKER');
  print('═══════════════════════════════════════════════════════════\n');
  
  print('📋 Your Profile Settings:');
  print('   Bot Time: $botTime (5:18 AM)');
  print('   Bot Days: ${botDays.join(", ")}');
  print('   Timezone: $timezone');
  print('   Last Activity: $lastActivityAt');
  print('');
  
  // Calculate delay
  final now = DateTime.now().toUtc();
  final lastActivity = lastActivityAt.toUtc();
  final hoursSinceActivity = now.difference(lastActivity).inHours;
  final delayHours = hoursSinceActivity < 72 ? (72 - hoursSinceActivity).clamp(0, 72) : 0;
  
  print('⏰ 72-Hour Auto-Delay Calculation:');
  print('   Current Time (UTC): $now');
  print('   Last Activity (UTC): $lastActivity');
  print('   Hours Since Activity: $hoursSinceActivity hours');
  print('   Delay Applied: $delayHours hours');
  print('   ${delayHours > 0 ? "⚠️ First message will be delayed by $delayHours hours" : "✅ No delay - messages start immediately"}');
  print('');
  
  // Build schedule
  final timeParts = botTime.split(':');
  final hour = int.parse(timeParts[0]);
  final minute = int.parse(timeParts[1]);
  
  final location = tz.getLocation('America/Los_Angeles');
  final nowLocal = tz.TZDateTime.now(location);
  final effectiveNow = delayHours > 0 
      ? nowLocal.add(Duration(hours: delayHours))
      : nowLocal;
  
  print('📍 Local Time Info:');
  print('   Current Time (Pacific): $nowLocal');
  print('   Effective Start Time: $effectiveNow');
  print('');
  
  final dayToWeekday = {
    'Monday': DateTime.monday,
    'Tuesday': DateTime.tuesday,
    'Wednesday': DateTime.wednesday,
    'Thursday': DateTime.thursday,
    'Friday': DateTime.friday,
    'Saturday': DateTime.saturday,
    'Sunday': DateTime.sunday,
  };
  
  final selectedWeekdays = botDays
      .map((day) => dayToWeekday[day])
      .whereType<int>()
      .toSet();
  
  final today = tz.TZDateTime(location, effectiveNow.year, effectiveNow.month, effectiveNow.day);
  var cursor = today.subtract(const Duration(days: 1));
  int count = 0;
  
  print('📅 NEXT 10 SCHEDULED BOT MESSAGES:');
  print('─────────────────────────────────────────────────────────\n');
  
  while (count < 10) {
    cursor = cursor.add(const Duration(days: 1));
    if (!selectedWeekdays.contains(cursor.weekday)) continue;
    
    final scheduledTime = tz.TZDateTime(
      location, cursor.year, cursor.month, cursor.day, hour, minute,
    );
    
    if (scheduledTime.isBefore(effectiveNow)) continue;
    
    count++;
    
    // Calculate time until message
    final timeUntil = scheduledTime.difference(nowLocal);
    final daysUntil = timeUntil.inDays;
    final hoursUntil = timeUntil.inHours % 24;
    final minutesUntil = timeUntil.inMinutes % 60;
    
    String timeUntilStr;
    if (daysUntil > 0) {
      timeUntilStr = '$daysUntil days, $hoursUntil hours, $minutesUntil minutes';
    } else if (hoursUntil > 0) {
      timeUntilStr = '$hoursUntil hours, $minutesUntil minutes';
    } else {
      timeUntilStr = '$minutesUntil minutes';
    }
    
    final dayName = _getDayName(scheduledTime.weekday);
    
    print('Message #$count:');
    print('   📆 Date: $dayName, ${scheduledTime.year}-${scheduledTime.month.toString().padLeft(2, '0')}-${scheduledTime.day.toString().padLeft(2, '0')}');
    print('   ⏰ Time: ${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')} Pacific');
    print('   ⏳ In: $timeUntilStr');
    
    if (count == 1) {
      print('   🔔 THIS IS YOUR NEXT MESSAGE!');
    }
    print('');
  }
  
  print('═══════════════════════════════════════════════════════════');
  print('✅ Total messages scheduled: 60');
  print('📱 Notification ID range: 1000-1059');
  print('═══════════════════════════════════════════════════════════\n');
  
  print('💡 TESTING TIP:');
  print('   To get a message in 2 minutes:');
  final testTime = nowLocal.add(Duration(minutes: 2));
  print('   1. Edit Profile');
  print('   2. Set Bot Time to: ${testTime.hour.toString().padLeft(2, '0')}:${testTime.minute.toString().padLeft(2, '0')}');
  print('   3. Save Profile');
  print('   4. Wait 2 minutes!');
  print('');
}

String _getDayName(int weekday) {
  switch (weekday) {
    case DateTime.monday: return 'Monday';
    case DateTime.tuesday: return 'Tuesday';
    case DateTime.wednesday: return 'Wednesday';
    case DateTime.thursday: return 'Thursday';
    case DateTime.friday: return 'Friday';
    case DateTime.saturday: return 'Saturday';
    case DateTime.sunday: return 'Sunday';
    default: return 'Unknown';
  }
}
