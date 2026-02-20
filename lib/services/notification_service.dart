import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  static const channelId = 'assignment_channel';
  static const channelName = 'Incident Assignments';
  static const channelDescription = 'Notifications for new incident assignments';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service.
  /// Must be called once at app startup.
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    // Create the notification channel for Android
    await _createNotificationChannel();
  }

  /// Create the notification channel for Android 8.0+
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Show a local notification.
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use millisecond timestamp as notification ID to ensure uniqueness
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _plugin.show(
      notificationId,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Handle notification tap
  static void _handleNotificationResponse(
    NotificationResponse response,
  ) {
    // TODO: Handle navigation based on payload if needed
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
