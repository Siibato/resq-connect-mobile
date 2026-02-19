import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'About Us',
          style: TextStyle(
            color: AppColors.textBlack,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'RESQ-Connect',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About RESQ-Connect',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'RESQ-Connect is an emergency response system designed to help communities report incidents quickly and efficiently. Our mission is to bridge the gap between citizens and emergency services, ensuring rapid response and better coordination during emergencies.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'With RESQ-Connect, you can:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Report emergencies instantly\n'
                    '• Access emergency hotlines\n'
                    '• Track your report status\n'
                    '• Work offline when needed\n'
                    '• Connect with local emergency services',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'support@resqconnect.com',
                  ),
                  const SizedBox(height: 12),
                  _buildContactRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: '0913 534 9201',
                  ),
                  const SizedBox(height: 12),
                  _buildContactRow(
                    icon: Icons.language_outlined,
                    label: 'Website',
                    value: 'www.resqconnect.com',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '© 2026 RESQ-Connect. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
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
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
