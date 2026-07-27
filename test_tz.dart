import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  final location = tz.getLocation('America/Los_Angeles');
  final now = tz.TZDateTime.now(location);
  print('now (TZDateTime): $now');
  print('now.toLocal(): ${now.toLocal()}');
  print('now.toLocal().toIso8601String(): ${now.toLocal().toIso8601String()}');
  print('DateTime.now().toIso8601String(): ${DateTime.now().toIso8601String()}');
  
  // also test parsing
  final dt = DateTime.parse(now.toLocal().toIso8601String());
  print('Parsed local: $dt');
  print('Parsed local hour: ${dt.hour}');
}
