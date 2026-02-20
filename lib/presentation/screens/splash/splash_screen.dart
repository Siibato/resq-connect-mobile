import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../responder/responder_home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    print('[Splash] Starting auth check');
    try {
      await ref.read(authNotifierProvider.notifier).checkAuthStatus();
      print('[Splash] Auth check completed');
    } catch (e) {
      print('[Splash] ERROR during auth check: $e');
    }

    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);
    print('[Splash] Auth state after check: ${authState.runtimeType}');
    print('[Splash] Auth state details: ${authState}');

    authState.maybeWhen(
      authenticated: (user) {
        print('[Splash] ✓ User authenticated: ${user.fullName}, isResponder: ${user.isResponder}');
        final screen = user.isResponder
            ? const ResponderHomeScreen()
            : const HomeScreen();
        print('[Splash] → Navigating to ${screen.runtimeType}');
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      orElse: () {
        print('[Splash] ✗ Not authenticated, navigating to OnboardingScreen');
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            SizedBox(
              width: 120,
              height: 120,
              child: Image.asset('assets/images/Logo.png'),
            ),
          ],
        ),
      ),
    );
  }
}
