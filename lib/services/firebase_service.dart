// Firebase Cloud Messaging service.
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Top-level background message handler (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Notification is displayed automatically by FCM on Android when app is in background
}

class FirebaseService {
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize FCM. Call this after Firebase.initializeApp().
  /// Returns the FCM token or null if not available.
  Future<String?> initialize() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Request permission (iOS + Android 13+)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get current token
    _fcmToken = await FirebaseMessaging.instance.getToken();

    // Refresh token when it changes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
    });

    return _fcmToken;
  }
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
