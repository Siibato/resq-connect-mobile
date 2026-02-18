import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/incident.dart';
import '../../providers/responder_provider.dart';
import 'responder_report_details_screen.dart';

class ReportAssignmentModal extends ConsumerStatefulWidget {
  final Incident incident;
  final VoidCallback onAccept;

  const ReportAssignmentModal({
    super.key,
    required this.incident,
    required this.onAccept,
  });

  @override
  ConsumerState<ReportAssignmentModal> createState() =>
      _ReportAssignmentModalState();
}

class _ReportAssignmentModalState extends ConsumerState<ReportAssignmentModal> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Close button
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textBlack,
                ),
              ),
            ),
          ),
          // Modal content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Alert icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.warning_amber,
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                const Text(
                  'Alert!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                const Text(
                  'Administrator assigned you a report.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Report summary section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location
                      _buildSummaryRow(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: widget.incident.displayLocation,
                      ),
                      const SizedBox(height: 12),
                      // Date reported
                      _buildSummaryRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date Reported',
                        value: widget.incident.createdAt != null
                            ? DateFormatter.formatDate(widget.incident.createdAt!)
                            : 'N/A',
                      ),
                      const SizedBox(height: 12),
                      // Reporter
                      _buildSummaryRow(
                        icon: Icons.person_outline,
                        label: 'Reporter',
                        value: widget.incident.reporterName ?? 'Unknown',
                      ),
                      const SizedBox(height: 12),
                      // Details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppColors.textGrey,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Report Details',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.incident.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textBlack,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Accept button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textBlack,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Accept Report',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textGrey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleAccept() async {
    setState(() => _isSubmitting = true);

    await ref.read(updateStatusProvider.notifier).update(
          widget.incident.id,
          'ACKNOWLEDGED',
        );

    if (mounted) {
      setState(() => _isSubmitting = false);

      // Close modal
      Navigator.pop(context);
      widget.onAccept();

      // Navigate to details screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResponderReportDetailsScreen(
            incidentId: widget.incident.id,
          ),
        ),
      );
    }
  }
}
