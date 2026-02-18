import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/incident.dart';
import '../../providers/incident_provider.dart';
import '../../providers/responder_provider.dart';
import '../../widgets/incident/incident_status_badge.dart';

class ResponderReportDetailsScreen extends ConsumerStatefulWidget {
  final String incidentId;

  const ResponderReportDetailsScreen({
    super.key,
    required this.incidentId,
  });

  @override
  ConsumerState<ResponderReportDetailsScreen> createState() =>
      _ResponderReportDetailsScreenState();
}

class _ResponderReportDetailsScreenState
    extends ConsumerState<ResponderReportDetailsScreen> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  Future<void> _updateStatus(String status) async {
    await ref.read(updateStatusProvider.notifier).update(
          widget.incidentId,
          status,
        );
  }

  @override
  Widget build(BuildContext context) {
    final incidentDetailsState = ref.watch(
      incidentDetailsProvider(widget.incidentId),
    );
    final updateStatusState = ref.watch(updateStatusProvider);

    return incidentDetailsState.maybeWhen(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Report Details'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (message) => Scaffold(
        appBar: AppBar(
          title: const Text('Report Details'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textGrey,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading incident',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      loaded: (incident) => Scaffold(
        appBar: AppBar(
          title: const Text('Report Details'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map view
              SizedBox(
                height: 300,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      incident.latitude,
                      incident.longitude,
                    ),
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.resq.connect',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            incident.latitude,
                            incident.longitude,
                          ),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Details section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status and type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IncidentStatusBadge(status: incident.status),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            incident.type.displayName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Location
                    _buildDetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: incident.displayLocation,
                    ),
                    const SizedBox(height: 16),
                    // Date reported
                    _buildDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date Reported',
                      value: incident.createdAt != null
                          ? DateFormatter.formatDate(incident.createdAt!)
                          : 'N/A',
                    ),
                    const SizedBox(height: 16),
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        incident.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textBlack,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Call citizen section
                    _buildCallSection(incident),
                    const SizedBox(height: 24),
                    // Update status section
                    _buildStatusUpdateSection(incident, updateStatusState),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      orElse: () => Scaffold(
        appBar: AppBar(
          title: const Text('Report Details'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
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
        ),
      ],
    );
  }

  Widget _buildCallSection(Incident incident) {
    final reporterName = incident.reporterName ?? 'Reporter';
    // Note: In a real app, you'd fetch the reporter's phone number from the incident data
    // For now, we'll use a placeholder
    const reporterPhone = '+1234567890'; // This would come from the incident data

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Call $reporterName',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Phone number with actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  color: AppColors.primaryBlue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reporterPhone,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textBlack,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _makePhoneCall(reporterPhone.replaceAll('+', '')),
                  child: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _copyToClipboard(reporterPhone),
                  child: const Icon(
                    Icons.content_copy_outlined,
                    color: AppColors.textGrey,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateSection(
    Incident incident,
    UpdateStatusState updateStatusState,
  ) {
    final isUpdating = updateStatusState is UpdateStatusLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Update report status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 12),
        // Status buttons
        Column(
          spacing: 8,
          children: [
            _buildStatusButton(
              label: 'Received',
              icon: Icons.visibility_outlined,
              status: 'PENDING',
              isActive: incident.status.toString() == 'IncidentStatus.pending',
              isDisabled: true, // Can't go back to pending
              isLoading: isUpdating,
              onTap: () => _updateStatus('PENDING'),
            ),
            _buildStatusButton(
              label: 'In progress',
              icon: Icons.autorenew_outlined,
              status: 'IN_PROGRESS',
              isActive:
                  incident.status.toString() == 'IncidentStatus.inProgress',
              isDisabled: incident.status.toString() == 'IncidentStatus.pending' ||
                  incident.status.toString() == 'IncidentStatus.resolved',
              isLoading: isUpdating,
              onTap: () => _updateStatus('IN_PROGRESS'),
            ),
            _buildStatusButton(
              label: 'Resolved',
              icon: Icons.check_circle_outlined,
              status: 'RESOLVED',
              isActive: incident.status.toString() == 'IncidentStatus.resolved',
              isDisabled: false,
              isLoading: isUpdating,
              onTap: () => _updateStatus('RESOLVED'),
            ),
          ],
        ),
        // Error message if any
        if (updateStatusState is UpdateStatusError)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                updateStatusState.message,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusButton({
    required String label,
    required IconData icon,
    required String status,
    required bool isActive,
    required bool isDisabled,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isDisabled || isLoading ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : Colors.white,
            border: Border.all(
              color: isDisabled ? Colors.grey.shade300 : AppColors.primaryBlue,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.textBlack,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
