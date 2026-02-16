import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/terms_conditions_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../report/report_history_screen.dart';
import '../settings/notification_settings_screen.dart';
import '../support/about_us_screen.dart';
import '../support/faqs_screen.dart';
import '../support/feedback_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: authState.maybeWhen(
        authenticated: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // User Info Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryBlue,
                      child: Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Registered Account',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Mobile',
                      value: user.mobile ?? 'Not set',
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: user.address ?? 'Not set',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Settings Section
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.edit_outlined,
                label: 'Account Settings',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.notifications_outlined,
                label: 'Notification Settings',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.feedback_outlined,
                label: 'Feedback',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FeedbackScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Support Section
              const Text(
                'Support',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.history,
                label: 'Report History',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReportHistoryScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.help_outline,
                label: 'FAQs',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FAQsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.info_outline,
                label: 'About Us',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AboutUsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Legal Section
              const Text(
                'Legal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 12),
              _ActionTile(
                icon: Icons.description_outlined,
                label: 'Terms and Conditions',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TermsConditionsScreen(
                      identifier: user.mobile ?? '',
                      isViewOnly: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Logout Button
              _ActionTile(
                icon: Icons.logout,
                label: 'Log Out',
                isDestructive: true,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref.read(authNotifierProvider.notifier).logout();
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        orElse: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppColors.primaryBlue,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : AppColors.textBlack,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
