// Local and push notification service.
// Push notifications require Firebase setup (google-services.json).
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  /// Request notification permission and set up handlers.
  Future<void> initialize() async {
    // TODO: implement after google-services.json is added
    // - Request permission via permission_handler
    // - Set up FirebaseMessaging.onMessage for foreground
    // - Set up FirebaseMessaging.onMessageOpenedApp for tap handling
  }

  /// Show a local notification.
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // TODO: implement with flutter_local_notifications
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
