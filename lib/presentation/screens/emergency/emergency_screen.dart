import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phone number copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context, String service, String number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          service,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Emergency Hotline',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _makePhoneCall(number.replaceAll(' ', ''));
            },
            icon: const Icon(Icons.phone, size: 18),
            label: const Text('Call Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with search and notification
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: AppColors.textGrey),
                          prefixIcon: Icon(Icons.search, color: AppColors.textGrey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Central Communications Hotline Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Central Communications Hotline',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'For emergency assistance, disaster response, and other urgent public safety concerns.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildHotlineButton(
                      context,
                      'Smart: 0913 534 92**',
                      '0913 534 9201',
                    ),
                    const SizedBox(height: 12),
                    _buildHotlineButton(
                      context,
                      'Globe: 0913 534 92**',
                      '0913 534 9202',
                    ),
                    const SizedBox(height: 12),
                    _buildHotlineButton(
                      context,
                      'Tel: 0913 534 92**',
                      '0913 534 9203',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Emergency Services Buttons
              _buildEmergencyServiceButton(
                context,
                icon: Icons.local_police_outlined,
                label: 'Police',
                number: '911',
              ),
              const SizedBox(height: 12),
              _buildEmergencyServiceButton(
                context,
                icon: Icons.medical_services_outlined,
                label: 'CDRRMO (Rescue)',
                number: '911',
              ),
              const SizedBox(height: 12),
              _buildEmergencyServiceButton(
                context,
                icon: Icons.local_fire_department_outlined,
                label: 'Fire Protection',
                number: '911',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotlineButton(BuildContext context, String label, String number) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () => _makePhoneCall(number.replaceAll(' ', '')),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _makePhoneCall(number.replaceAll(' ', '')),
                  icon: const Icon(
                    Icons.phone,
                    color: Color(0xFFE57373),
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => _copyToClipboard(context, number),
                  icon: const Icon(
                    Icons.content_copy,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyServiceButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String number,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () => _showEmergencyDialog(context, label, number),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardDark,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
