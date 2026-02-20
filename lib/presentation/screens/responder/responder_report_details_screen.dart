import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/incident.dart';
import '../../providers/incident_provider.dart';
import '../../providers/responder_provider.dart';
import '../../widgets/incident/incident_status_badge.dart';
import 'responder_home_screen.dart';

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
  bool _autoAcknowledged = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Auto-acknowledge when opening a pending report
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoAcknowledgeIfPending();
    });
  }

  void _autoAcknowledgeIfPending() {
    if (_autoAcknowledged) return; // Prevent duplicate calls

    final incidentDetailsState = ref.read(
      incidentDetailsProvider(widget.incidentId),
    );
    incidentDetailsState.maybeWhen(
      loaded: (incident) {
        // Auto-start responding when opening a PENDING report
        if (incident.status == IncidentStatus.pending) {
          _autoAcknowledged = true;
          _updateStatus('ACKNOWLEDGED');
        }
      },
      orElse: () {},
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _goToHome() async {
    if (mounted) {
      // Navigate directly to ResponderHomeScreen using pushAndRemoveUntil to clear the stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ResponderHomeScreen()),
        (route) => false,
      );
    }

    // Refresh the assigned incidents in the background (don't wait for it)
    // This will update the list after we've already navigated
    ref.read(assignedIncidentsProvider.notifier).refresh();
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
            onPressed: _goToHome,
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
            onPressed: _goToHome,
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
            onPressed: _goToHome,
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
                    // Media section (if available)
                    if (incident.mediaUrls.isNotEmpty) ...[
                      _buildMediaSection(incident),
                      const SizedBox(height: 24),
                    ],
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
            onPressed: _goToHome,
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

  bool _isVideoUrl(String url) {
    final extension = url.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'].contains(extension) ||
        url.contains('/video/upload/');
  }

  Widget _buildMediaSection(Incident incident) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.image_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Attachments (${incident.mediaUrls.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: incident.mediaUrls.length,
          itemBuilder: (context, index) {
            final mediaUrl = incident.mediaUrls[index];
            final isVideo = _isVideoUrl(mediaUrl);
            return GestureDetector(
              onTap: () {
                _showMediaPreview(context, mediaUrl, isVideo);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Thumbnail
                    if (isVideo)
                      Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(
                            Icons.videocam_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      )
                    else
                      Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  color: AppColors.textGrey,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Failed to load',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    // Overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Play icon only for videos
                    if (isVideo)
                      const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showMediaPreview(BuildContext context, String mediaUrl, bool isVideo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(0),
        child: isVideo
            ? _VideoPreviewDialog(videoUrl: mediaUrl)
            : _ImagePreviewDialog(imageUrl: mediaUrl),
      ),
    );
  }

  Widget _buildCallSection(Incident incident) {
    final reporterName = incident.reporterName ?? 'Reporter';
    final reporterPhone = incident.reporterMobile ?? 'Unknown';
    final hasValidPhone = incident.reporterMobile != null && incident.reporterMobile!.isNotEmpty;

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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: hasValidPhone ? AppColors.textBlack : AppColors.error,
                    ),
                  ),
                ),
                if (hasValidPhone) ...[
                  const SizedBox(width: 8),
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
    final nextStatus = incident.status.nextTransition;
    final nextStatusServerValue = incident.status.nextTransitionServerValue;

    // Build button info based on next status
    String buttonLabel = '';
    String buttonSubtitle = '';
    IconData buttonIcon = Icons.help_outline;

    if (nextStatus == IncidentStatus.acknowledged) {
      buttonLabel = 'Acknowledge';
      buttonSubtitle = 'Mark as Acknowledged';
      buttonIcon = Icons.check_outlined;
    } else if (nextStatus == IncidentStatus.inProgress) {
      buttonLabel = 'Start Responding';
      buttonSubtitle = 'Mark as In Progress';
      buttonIcon = Icons.autorenew_outlined;
    } else if (nextStatus == IncidentStatus.resolved) {
      buttonLabel = 'Mark Resolved';
      buttonSubtitle = 'Incident complete';
      buttonIcon = Icons.check_circle_outlined;
    }

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
        // Status button - only show if there's a next transition
        if (nextStatus != null && nextStatusServerValue != null)
          _buildStatusButton(
            label: buttonLabel,
            subtitle: buttonSubtitle,
            icon: buttonIcon,
            isLoading: isUpdating,
            onTap: () => _updateStatus(nextStatusServerValue),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Incident Resolved',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This incident has been resolved and no further actions are needed.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
    required String subtitle,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          border: Border.all(color: AppColors.primaryBlue),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
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
    );
  }
}

class _ImagePreviewDialog extends StatelessWidget {
  final String imageUrl;

  const _ImagePreviewDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoPreviewDialog extends StatefulWidget {
  final String videoUrl;

  const _VideoPreviewDialog({required this.videoUrl});

  @override
  State<_VideoPreviewDialog> createState() => _VideoPreviewDialogState();
}

class _VideoPreviewDialogState extends State<_VideoPreviewDialog> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      }).catchError((e) {
        // Video initialization error - will show loading state
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black,
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
        ),
        // Play/Pause button
        if (_controller.value.isInitialized)
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
          ),
        // Close button
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
