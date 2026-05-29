import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsService {

  LocalNotificationsService._internal();

  static final LocalNotificationsService _instance = LocalNotificationsService._internal();

  factory LocalNotificationsService.instance() => _instance;

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  final _androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');

  final _iosInitializationSettings = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    defaultPresentAlert: true,
    defaultPresentBadge: true,
    defaultPresentSound: true,
    defaultPresentBanner: true,
    defaultPresentList: true,
  );

  final _androidChannel = const AndroidNotificationChannel(
    'channel_id',
    'channel name',
    description: 'Android push notification channel',
    importance: Importance.max
  );

  bool _isFlutterLocalNotificationInitialized = false;
  Future<void>? _initializationFuture;

  int _notificationIdCounter = 0;

  // IDs 1000–1059 are reserved for bot notifications
  static const int _botNotificationBaseId = 1000;
  static const int _botNotificationCount = 60;

  // IDs 2000–2001 are reserved for goal statement notifications
  static const int _goalStatementWarningId = 2000;
  static const int _goalStatementExpiryId  = 2001;


  Future<void> init() async {

    if(_isFlutterLocalNotificationInitialized){
      return;
    }

    if(_initializationFuture != null){
      return _initializationFuture;
    }

    _initializationFuture = _initInternal();
    return _initializationFuture;
  }

  Future<void> _initInternal() async {
    print("Initializing LocalNotificationsService...");
    _flutterLocalNotificationsPlugin  = FlutterLocalNotificationsPlugin();

    final initializeSettings  = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: _iosInitializationSettings
    );


    bool? initialized = await _flutterLocalNotificationsPlugin.initialize(settings: initializeSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response){
          print("Notification response: ${response.payload}");
    });

    print("Local notifications initialized successfully: $initialized");

    if (Platform.isIOS) {
      final iosPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin == null) {
        print("WARNING: Could not resolve IOSFlutterLocalNotificationsPlugin implementation");
      } else {
        bool? granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        print("iOS permissions requested. Status (granted): $granted");
      }
    }

    // Create Android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    _isFlutterLocalNotificationInitialized = true;
  }

  Future<void> showNotification(
      String? title,
      String? body,
      String? payload,
      ) async {

      print("Attempting to show notification: $title");
      await init();

      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high
          );

      const iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
          presentList: true
      );


      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails
      );

      try {
        final id = _notificationIdCounter++;
        print("Calling plugin show with id: $id");
        await _flutterLocalNotificationsPlugin.show(
          id: id,
          title: title,
          body: body,
          notificationDetails: notificationDetails,
          payload: payload
        );
        print("Plugin show method called successfully for id: $id");
      } catch (e) {
        print("Error showing notification: $e");
      }
  }

  Future<void> cancelBotNotifications() async {
    await init();
    for (int i = 0; i < _botNotificationCount; i++) {
      await _flutterLocalNotificationsPlugin.cancel(id: _botNotificationBaseId + i);
    }
    print('Bot notifications cancelled.');
  }

  /// Schedule a pre-built list of bot notifications.
  /// Each entry supplies the notification ID, scheduled time, title, and body.
  Future<void> scheduleBotNotifications(
    List<({int id, tz.TZDateTime scheduledAt, String title, String body})> schedule,
  ) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel name',
      channelDescription: 'Android push notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    int scheduled = 0;
    for (final entry in schedule) {
      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id: entry.id,
          title: entry.title,
          body: entry.body,
          scheduledDate: entry.scheduledAt,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        scheduled++;
      } catch (e) {
        print('Error scheduling bot notification id=${entry.id}: $e');
      }
    }

    print('Scheduled $scheduled bot notifications.');
  }

  Future<void> cancelGoalStatementNotifications() async {
    await init();
    await _flutterLocalNotificationsPlugin.cancel(id: _goalStatementWarningId);
    await _flutterLocalNotificationsPlugin.cancel(id: _goalStatementExpiryId);
    print('Goal statement notifications cancelled.');
  }

  Future<void> scheduleGoalStatementNotifications(DateTime createdAt) async {
    await cancelGoalStatementNotifications();

    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel name',
      channelDescription: 'Android push notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    final warningTime = tz.TZDateTime.from(createdAt.add(const Duration(days: 83)), location);
    final expiryTime  = tz.TZDateTime.from(createdAt.add(const Duration(days: 90)), location);

    if (warningTime.isAfter(now)) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: _goalStatementWarningId,
        title: 'Goal Statement Expiring Soon',
        body: 'Your goal statement expires in 1 week. Update it to stay visible in the forum!',
        scheduledDate: warningTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    if (expiryTime.isAfter(now)) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: _goalStatementExpiryId,
        title: 'Goal Statement Expired',
        body: 'Your goal statement has expired. Share a new one with the community!',
        scheduledDate: expiryTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    print('Goal statement notifications scheduled.');
  }

}
