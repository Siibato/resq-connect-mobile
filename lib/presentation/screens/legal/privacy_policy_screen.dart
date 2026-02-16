import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your privacy matters to us',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '1. Information We Collect',
              content:
                  'We collect information that you provide directly to us, including:\n\n'
                  '• Personal Information: Name, mobile number, email address, and residential address\n'
                  '• Location Data: GPS coordinates when you submit incident reports\n'
                  '• Media Content: Photos and videos you upload with incident reports\n'
                  '• Report Details: Descriptions and categories of incidents you report\n'
                  '• Device Information: Device type, operating system, and unique device identifiers',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '2. How We Use Your Information',
              content:
                  'We use the collected information for the following purposes:\n\n'
                  '• Emergency Response: To facilitate rapid emergency response and coordinate with relevant authorities\n'
                  '• Location Services: To help emergency responders locate you accurately\n'
                  '• Service Improvement: To improve our app features and user experience\n'
                  '• Communication: To send you updates about your incident reports\n'
                  '• Legal Compliance: To comply with legal obligations and law enforcement requests',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '3. Information Sharing',
              content:
                  'We share your information only in specific circumstances:\n\n'
                  '• Emergency Services: Your report details, location, and contact information are shared with relevant emergency services (Police, Fire, Medical) when you submit a report\n'
                  '• Government Authorities: When required by law or in response to legal processes\n'
                  '• Service Providers: With trusted third-party service providers who help us operate the app\n\n'
                  'We do not sell your personal information to third parties.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '4. Data Security',
              content:
                  'We implement appropriate security measures to protect your personal information:\n\n'
                  '• Encryption: All data transmitted between your device and our servers is encrypted\n'
                  '• Secure Storage: Your data is stored on secure servers with restricted access\n'
                  '• Authentication: We use secure authentication methods to verify your identity\n\n'
                  'However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '5. Location Data',
              content:
                  'RESQ-Connect collects and uses location data when:\n\n'
                  '• You submit an incident report\n'
                  '• You use the map feature to select a location\n'
                  '• You enable location services in the app\n\n'
                  'Location data is collected with your permission and can be disabled in your device settings. However, disabling location services may limit some app functionality.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '6. Data Retention',
              content:
                  'We retain your personal information for as long as necessary to:\n\n'
                  '• Provide our services to you\n'
                  '• Comply with legal obligations\n'
                  '• Resolve disputes and enforce our agreements\n\n'
                  'Incident reports may be retained for administrative and legal purposes even after your account is deleted.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '7. Your Rights',
              content:
                  'You have the following rights regarding your personal data:\n\n'
                  '• Access: Request a copy of your personal information\n'
                  '• Correction: Request correction of inaccurate information\n'
                  '• Deletion: Request deletion of your personal information (subject to legal requirements)\n'
                  '• Objection: Object to certain processing of your data\n\n'
                  'To exercise these rights, contact us at privacy@resqconnect.com',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '8. Children\'s Privacy',
              content:
                  'RESQ-Connect is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child under 13, please contact us immediately.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '9. Changes to This Policy',
              content:
                  'We may update this Privacy Policy from time to time. We will notify you of any significant changes by:\n\n'
                  '• Posting the new policy in the app\n'
                  '• Sending you a notification\n'
                  '• Updating the "Last Updated" date\n\n'
                  'Your continued use of the app after changes are posted constitutes acceptance of the updated policy.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '10. Contact Us',
              content:
                  'If you have questions or concerns about this Privacy Policy, please contact us:\n\n'
                  'Email: privacy@resqconnect.com\n'
                  'Phone: 0913 534 9201\n'
                  'Address: RESQ-Connect Privacy Office',
            ),
            const SizedBox(height: 32),
            const Text(
              'Last Updated: February 2026',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textBlack,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
