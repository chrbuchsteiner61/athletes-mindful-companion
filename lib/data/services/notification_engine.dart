import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationEngine {
  NotificationEngine();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> schedulePreSessionReminder({
    required String impulse,
    required DateTime scheduledTime,
    int id = 1001,
  }) async {
    await init();
    await _plugin.schedule(
      id,
      'Dein Fokus fürs nächste Training',
      impulse,
      scheduledTime,
      _channelDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> schedulePostSessionCheckin({
    required DateTime scheduledTime,
    int id = 1002,
  }) async {
    await init();
    await _plugin.schedule(
      id,
      'Zeit für deine Reflexion',
      'Lass uns die Gefühle deiner Einheit festhalten, bevor sie verblassen.',
      scheduledTime,
      _channelDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  NotificationDetails _channelDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'amc_reminders',
        'Mindful Companion Erinnerungen',
        channelDescription: 'Brücken-Strategie: Intention & Reflexion',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }
}
