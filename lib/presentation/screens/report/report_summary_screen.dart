import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/incident.dart';
import '../home/home_screen.dart';

class ReportSummaryScreen extends StatelessWidget {
  final Incident incident;

  const ReportSummaryScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your report\nsummary.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32),
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: incident.displayLocation,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Date Reported',
                value: incident.createdAt != null
                    ? DateFormat('MMMM dd, yyyy – hh:mm a')
                        .format(incident.createdAt!)
                    : DateFormat('MMMM dd, yyyy – hh:mm a')
                        .format(DateTime.now()),
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                icon: Icons.warning_amber_outlined,
                label: 'Category',
                value: incident.type.displayName,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                icon: Icons.edit_outlined,
                label: 'Report Details',
                value: incident.description.isNotEmpty
                    ? incident.description
                    : 'No details provided',
              ),
              const SizedBox(height: 32),
              const Text(
                'Your report status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildStatusBadge(
                    'Received',
                    AppColors.statusReceived,
                    isActive: incident.status == IncidentStatus.pending,
                  ),
                  _buildStatusBadge(
                    'In Progress',
                    AppColors.statusInProgress,
                    isActive: incident.status == IncidentStatus.acknowledged ||
                        incident.status == IncidentStatus.inProgress,
                  ),
                  _buildStatusBadge(
                    'Resolved',
                    AppColors.statusResolved,
                    isActive: incident.status == IncidentStatus.resolved,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Back to Home Page',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 4),
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
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, Color color, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : AppColors.textGrey,
        ),
      ),
    );
  }
}
