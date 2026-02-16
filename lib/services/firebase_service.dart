// Firebase Cloud Messaging service.
// Requires google-services.json to be added to android/app/ before full use.
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseService {
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize FCM. Call this after Firebase.initializeApp().
  /// Returns the FCM token or null if not available.
  Future<String?> initialize() async {
    // TODO: implement after google-services.json is added
    // final messaging = FirebaseMessaging.instance;
    // await messaging.requestPermission();
    // _fcmToken = await messaging.getToken();
    // messaging.onTokenRefresh.listen((token) { _fcmToken = token; });
    return null;
  }
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
