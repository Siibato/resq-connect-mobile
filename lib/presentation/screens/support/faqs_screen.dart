import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

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
          'FAQs',
          style: TextStyle(
            color: AppColors.textBlack,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 24),
          _buildFAQTile(
            question: 'How do I report an emergency?',
            answer:
                'Tap the "Emergency" tab at the bottom of the screen, then select the appropriate emergency service (Police, CDRRMO, or Fire Protection). Fill in the details and submit your report.',
          ),
          const SizedBox(height: 12),
          _buildFAQTile(
            question: 'Can I report incidents without internet?',
            answer:
                'Yes! The app works offline. Your report will be saved locally and automatically submitted once you regain internet connectivity.',
          ),
          const SizedBox(height: 12),
          _buildFAQTile(
            question: 'How do I track my report status?',
            answer:
                'Go to the "My profile" tab and tap on "Report History". You\'ll see all your submitted reports and their current status.',
          ),
          const SizedBox(height: 12),
          _buildFAQTile(
            question: 'Why does the app need location permission?',
            answer:
                'Location permission helps emergency responders locate you quickly and accurately. Your location is only shared when you submit a report.',
          ),
          const SizedBox(height: 12),
          _buildFAQTile(
            question: 'How do I update my profile information?',
            answer:
                'Go to "My profile" tab, then tap on "Account Settings". You can update your personal information from there.',
          ),
          const SizedBox(height: 12),
          _buildFAQTile(
            question: 'What should I do if I submitted a false report?',
            answer:
                'Contact the emergency hotline immediately and inform them. You can find the hotline numbers in the Emergency tab.',
          ),
          const SizedBox(height: 12),
          _buildFAQTile(
            question: 'How secure is my personal information?',
            answer:
                'We take your privacy seriously. All data is encrypted and only shared with authorized emergency services when you submit a report. Read our Privacy Policy for more details.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTile({
    required String question,
    required String answer,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: AppColors.primaryBlue,
          collapsedIconColor: AppColors.textGrey,
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
