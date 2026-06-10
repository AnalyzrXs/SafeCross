import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles initialization and display of the always-on SafeCross notification.
class NotificationService {
  NotificationService();

  static const _persistentNotificationId = 1;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Shows a silent, ongoing notification that cannot be swiped away.
  Future<void> ensurePersistentNotification() async {
    await initialize();
    const androidDetails = AndroidNotificationDetails(
      'safecross_guardian_channel',
      'SafeCross Guardian',
      channelDescription: 'Keeps SafeCross alerts alive in the background',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      enableLights: false,
      category: AndroidNotificationCategory.service,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentSound: false,
      presentBadge: false,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      _persistentNotificationId,
      'SafeCross',
      'Monitoring nearby crossings for you',
      notificationDetails,
    );
  }

  Future<void> dispose() async {
    await _plugin.cancel(_persistentNotificationId);
  }
}
