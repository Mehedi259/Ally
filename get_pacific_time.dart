import 'package:timezone/standalone.dart' as tz;

void main() async {
  await tz.initializeTimeZone();
  
  final pacific = tz.getLocation('America/Los_Angeles');
  final bangladesh = tz.getLocation('Asia/Dhaka');
  
  final nowPacific = tz.TZDateTime.now(pacific);
  final nowBangladesh = tz.TZDateTime.now(bangladesh);
  
  print('═══════════════════════════════════════════════════');
  print('🕐 CURRENT TIME CHECKER');
  print('═══════════════════════════════════════════════════\n');
  
  print('📍 Bangladesh Time (Your Phone):');
  print('   ${nowBangladesh.hour.toString().padLeft(2, '0')}:${nowBangladesh.minute.toString().padLeft(2, '0')} AM/PM');
  print('   ${nowBangladesh.day}-${nowBangladesh.month}-${nowBangladesh.year}');
  print('');
  
  print('📍 Pacific Time (Your Profile):');
  print('   ${nowPacific.hour.toString().padLeft(2, '0')}:${nowPacific.minute.toString().padLeft(2, '0')}');
  print('   ${nowPacific.day}-${nowPacific.month}-${nowPacific.year}');
  print('');
  
  print('═══════════════════════════════════════════════════');
  print('🎯 TO TEST BOT MESSAGE NOW:');
  print('═══════════════════════════════════════════════════\n');
  
  final testTime = nowPacific.add(Duration(minutes: 2));
  
  print('1. Open Edit Profile');
  print('2. Keep Timezone: US/Pacific');
  print('3. Set Bot Time to: ${testTime.hour.toString().padLeft(2, '0')}:${testTime.minute.toString().padLeft(2, '0')}');
  print('4. Save Profile');
  print('5. Wait 2 minutes...');
  print('6. 🔔 Notification will come!\n');
  
  print('OR in 5 minutes:');
  final testTime5 = nowPacific.add(Duration(minutes: 5));
  print('   Bot Time: ${testTime5.hour.toString().padLeft(2, '0')}:${testTime5.minute.toString().padLeft(2, '0')}\n');
  
  print('═══════════════════════════════════════════════════');
}
