import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './core/constants/env_config.dart';
import './core/theme/app_colors.dart';
import './presentation/screens/splash/splash_screen.dart';
import './services/firebase_service.dart';
import './services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  await EnvConfig.initialize(
    envFile: const String.fromEnvironment('ENV_FILE', defaultValue: '.env'),
  );

  // Initialize Firebase first
  final firebaseService = FirebaseService();
  await firebaseService.initialize();

  // Then initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Wire FCM foreground messages to local notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      notificationService.showNotification(
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
      );
    }
  });

  runApp(
    ProviderScope(
      overrides: [
        firebaseServiceProvider.overrideWithValue(firebaseService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RESQ-Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}
