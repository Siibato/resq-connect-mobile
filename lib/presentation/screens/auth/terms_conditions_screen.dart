import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../responder/responder_home_screen.dart';

class TermsConditionsScreen extends ConsumerStatefulWidget {
  final String identifier;
  final bool isViewOnly;

  const TermsConditionsScreen({
    super.key,
    required this.identifier,
    this.isViewOnly = false,
  });

  @override
  ConsumerState<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends ConsumerState<TermsConditionsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: widget.isViewOnly
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(
            color: AppColors.textBlack,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please read and accept our terms and conditions',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTermsContent(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          if (!widget.isViewOnly)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: _hasScrolledToBottom
                            ? (value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              }
                            : null,
                        activeColor: AppColors.primaryBlue,
                      ),
                      Expanded(
                        child: Text(
                          'I have read and agree to the Terms and Conditions',
                          style: TextStyle(
                            fontSize: 14,
                            color: _hasScrolledToBottom
                                ? AppColors.textBlack
                                : AppColors.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _agreedToTerms
                          ? () {
                              final authState = ref.read(authNotifierProvider);
                              authState.maybeWhen(
                                authenticated: (user) {
                                  final screen = user.isResponder
                                      ? const ResponderHomeScreen()
                                      : const HomeScreen();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => screen),
                                    (route) => false,
                                  );
                                },
                                orElse: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const HomeScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        disabledBackgroundColor: AppColors.textGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Accept and Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTermsContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. Acceptance of Terms',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'By accessing and using the RESQ-Connect mobile application, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these terms, please do not use this application.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textBlack,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24),
        Text(
          '2. Use License',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Permission is granted to temporarily use RESQ-Connect for personal, non-commercial purposes only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n• Modify or copy the materials\n• Use the materials for any commercial purpose\n• Attempt to decompile or reverse engineer any software contained in the app\n• Remove any copyright or other proprietary notations from the materials',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textBlack,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24),
        Text(
          '3. Data Collection and Privacy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'RESQ-Connect collects and processes personal data including your name, contact information, location data, and incident reports. This information is used solely for the purpose of emergency response and disaster management. We are committed to protecting your privacy and maintaining the confidentiality of your personal information.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textBlack,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24),
        Text(
          '4. User Responsibilities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'As a user of RESQ-Connect, you agree to:\n\n• Provide accurate and truthful information when submitting incident reports\n• Not misuse the emergency reporting system for false alarms or pranks\n• Use the application only for legitimate emergency and disaster-related purposes\n• Respect the privacy and safety of others when using location-sharing features\n• Comply with all applicable local, state, and national laws',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textBlack,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24),
        Text(
          '5. Incident Reporting',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'When submitting incident reports through RESQ-Connect:\n\n• Ensure all information provided is accurate to the best of your knowledge\n• Include relevant details that may help emergency responders\n• Do not submit false or misleading reports\n• Understand that your report may be shared with relevant emergency services and authorities\n• Photos and location data you submit may be used for emergency response coordination',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textBlack,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24),
        Text(
          '6. Location Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'RESQ-Connect uses GPS and location services to help emergency responders locate you. By using this app, you consent to the collection and sharing of your location data with emergency services when you submit a report. You can control location permissions through your device settings.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textBlack,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24),
        Text(
          '7. Disclaimer of Warranties',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'RESQ-Connect is provided "as is" without warranty of any kind. We do not guarantee that the app will be error-free, uninterrupted, or that it will meet your specific requirements. While we strive to provide reliable emergency reporting services, we cannot guarantee response times or outcomes.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textBlack,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24),
        Text(
          '8. Limitation of Liability',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'In no event shall RESQ-Connect or its developers be liable for any damages arising out of the use or inability to use the application, even if we have been notified of the possibility of such damages. This includes but is not limited to damages for loss of data, loss of profit, or service interruption.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textBlack,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24),
        Text(
          '9. Changes to Terms',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'We reserve the right to modify these terms at any time. We will notify users of any significant changes through the application. Your continued use of RESQ-Connect after changes are posted constitutes your acceptance of the revised terms.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textBlack,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24),
        Text(
          '10. Contact Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'If you have any questions about these Terms and Conditions, please contact us through the app\'s support section or email us at support@resqconnect.com',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textBlack,
            height: 1.5,
          ),
        ),
        SizedBox(height: 32),
        Text(
          'Last Updated: February 2026',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textGrey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
