import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/constants/incident_choices.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../../data/models/offline_report_model.dart';
import '../../../domain/entities/incident.dart';
import '../../../services/location_service.dart';
import '../../../services/sms_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';

class OfflineReportScreen extends ConsumerStatefulWidget {
  const OfflineReportScreen({super.key});

  @override
  ConsumerState<OfflineReportScreen> createState() =>
      _OfflineReportScreenState();
}

class _OfflineReportScreenState extends ConsumerState<OfflineReportScreen> {
  String? _selectedType;
  final _detailsController = TextEditingController();
  String? _selectedChoice; // Track which predefined choice is selected
  bool _showCustomField = false; // Track if "Others" is selected
  bool _isLoading = false;
  late LocationService _locationService;
  double? _latitude;
  double? _longitude;
  String? _locationError;
  List<OfflineReport> _draftReports = [];

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _loadDraftReports();
    _loadLastLocation();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _loadLastLocation() async {
    try {
      final position = await _locationService.getLastKnownLocation();
      if (position != null) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationError = null;
        });
      } else {
        setState(() {
          _locationError = 'No cached location available';
        });
      }
    } catch (e) {
      setState(() {
        _locationError = 'Error loading location: ${e.toString()}';
      });
    }
  }

  void _selectChoice(String choice) {
    setState(() {
      _selectedChoice = choice;
      _showCustomField = false;
      _detailsController.text = choice;
    });
  }

  void _selectOthers() {
    setState(() {
      _selectedChoice = null;
      _showCustomField = true;
      _detailsController.clear();
    });
  }

  void _loadDraftReports() async {
    try {
      final dbHelper = ref.read(databaseHelperProvider);
      final reports = await dbHelper.getDraftSmsReports();
      setState(() {
        _draftReports =
            reports.map((r) => OfflineReport.fromJson(r)).toList();
      });
    } catch (e) {
      // Silent fail
    }
  }

  void _handleSendReport() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select incident type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter incident details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available - cannot send report'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authState = ref.read(authNotifierProvider);
    final userName = authState.maybeWhen(
      authenticated: (user) => user.fullName,
      orElse: () => 'Unknown',
    );

    // Format SMS: [NAME] - [TYPE] [LAT] [LNG]. [DETAILS]
    final smsText =
        '$userName - $_selectedType ${_latitude!.toStringAsFixed(4)} ${_longitude!.toStringAsFixed(4)}. ${_detailsController.text.trim()}';

    setState(() => _isLoading = true);

    try {
      final smsService = SmsService();
      final gatewayNumber = '+639453859979';
      final incidentType = _stringToIncidentType(_selectedType ?? '');

      // Try to send SMS programmatically
      try {
        await smsService.sendReport(
          gatewayNumber: gatewayNumber,
          type: incidentType,
          latitude: _latitude!,
          longitude: _longitude!,
          description: _detailsController.text.trim(),
        );
        // SMS sent successfully
        _saveOfflineReport(smsText, userName, true);
        _showSuccessDialog();
      } catch (e) {
        // SMS sending failed - fall back to SMS intent
        // Use 'smsto' scheme which is more reliable on Android 11+
        final smsUri = Uri(scheme: 'smsto', path: gatewayNumber, queryParameters: {
          'body': smsText,
        });

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
          // User opened SMS app - mark as sent since message is ready to send
          _saveOfflineReport(smsText, userName, true);
          _showIntentDialog();
        } else {
          // No SMS capability - show error
          _showErrorDialog();
        }
      }
    } catch (e) {
      // Show error on unexpected failures
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _saveOfflineReport(String smsText, String userName, bool sent) async {
    try {
      final dbHelper = ref.read(databaseHelperProvider);
      final report = OfflineReport(
        id: const Uuid().v4(),
        citizenId: ref.read(authNotifierProvider).maybeWhen(
              authenticated: (user) => user.id,
              orElse: () => '',
            ),
        citizenName: userName,
        type: _selectedType ?? 'UNKNOWN',
        latitude: _latitude ?? 0,
        longitude: _longitude ?? 0,
        description: _detailsController.text.trim(),
        smsText: smsText,
        status: sent ? 'SENT' : 'DRAFT',
        createdAt: DateTime.now(),
        sentAt: sent ? DateTime.now() : null,
      );

      await dbHelper.insertSmsOfflineReport(report.toJson());

      // Clear form and only add to draft list if it's a draft
      setState(() {
        _selectedType = null;
        _selectedChoice = null;
        _showCustomField = false;
        _detailsController.clear();
        if (!sent) {
          _draftReports.insert(0, report);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('SMS Sent'),
        content: const Text(
          'Your incident report has been sent via SMS. The responder team will receive and process it shortly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showIntentDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('SMS Ready to Send'),
        content: const Text(
          'The SMS app has opened with your message pre-filled. Please tap Send to submit your report.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Unable to Send SMS'),
        content: const Text(
          'Could not open SMS app. Please check:\n\n'
          '• SMS app is installed and enabled\n'
          '• SMS app is set as default\n'
          '• Device has SMS capability\n\n'
          'Try opening your Messages app and sending the SMS manually.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _retryDraftReport(OfflineReport report) async {
    try {
      // Try to send via SmsService first
      final smsService = SmsService();
      final gatewayNumber = '+639453859979';

      // Parse the SMS text to extract coordinates
      // Format: [NAME] - [TYPE] [LAT] [LNG]. [DETAILS]
      try {
        final parts = report.smsText.split(' ');
        if (parts.length >= 5) {
          final typePart = parts[2]; // TYPE is at index 2
          final latStr = parts[3];
          final lngStr = parts[4].replaceAll('.', '');

          final lat = double.tryParse(latStr);
          final lng = double.tryParse(lngStr);

          if (lat != null && lng != null) {
            final incidentType = _stringToIncidentType(typePart);
            await smsService.sendReport(
              gatewayNumber: gatewayNumber,
              type: incidentType,
              latitude: lat,
              longitude: lng,
              description: report.smsText.split('. ').skip(1).join('. '),
            );

            // Mark as sent
            final dbHelper = ref.read(databaseHelperProvider);
            await dbHelper.markSmsSent(report.id);
            _loadDraftReports();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report sent successfully'),
                  backgroundColor: AppColors.primaryBlue,
                ),
              );
            }
            return;
          }
        }
      } catch (e) {
        // Parsing failed, fall back to SMS intent
      }

      // Fall back to SMS intent
      final smsUri = Uri(scheme: 'smsto', path: gatewayNumber, queryParameters: {
        'body': report.smsText,
      });

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        // Mark as sent since SMS app is now open
        final dbHelper = ref.read(databaseHelperProvider);
        await dbHelper.markSmsSent(report.id);
        _loadDraftReports();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('SMS app opened. Please send the message.'),
              backgroundColor: AppColors.primaryBlue,
            ),
          );
        }
      } else {
        // No SMS capability
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open SMS app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteDraftReport(String reportId) async {
    try {
      final dbHelper = ref.read(databaseHelperProvider);
      await dbHelper.deleteSmsReport(reportId);
      _loadDraftReports();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report deleted'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IncidentType _stringToIncidentType(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return IncidentType.fire;
      case 'medical':
        return IncidentType.medical;
      case 'police':
        return IncidentType.police;
      default:
        return IncidentType.police; // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to connectivity changes and reload drafts when transitioning to online
    ref.listen(isOfflineProvider, (previous, next) {
      next.whenData((isOffline) {
        // When transitioning from offline to online, trigger sync
        if (previous != null && previous.when(
          data: (wasOffline) => wasOffline,
          loading: () => false,
          error: (_, __) => false,
        )) {
          // Was offline, now online - trigger sync if needed
          if (!isOffline) {
            _loadDraftReports();
          }
        }
      });
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Report (Offline Mode)'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.textGrey,
            tabs: [
              Tab(text: 'New Report'),
              Tab(text: 'Unsent Reports'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNewReportTab(),
            _buildDraftsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You are in offline mode. Reports will be sent via SMS.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Auto-filled fields
          _buildInfoField('Name', ref.read(authNotifierProvider).maybeWhen(
                authenticated: (user) => user.fullName,
                orElse: () => 'Not logged in',
              )),
          const SizedBox(height: 16),

          _buildInfoField(
            'Location',
            _latitude != null && _longitude != null
                ? '${_latitude!.toStringAsFixed(4)} ${_longitude!.toStringAsFixed(4)}'
                : _locationError ?? 'Loading...',
          ),
          const SizedBox(height: 24),

          // Type selector
          const Text(
            'Incident Type *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedType,
              hint: const Text('Select incident type'),
              underline: const SizedBox(),
              items: ['FIRE', 'MEDICAL', 'POLICE']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedType = value);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Choice buttons
          _buildChoiceButtons(),

          // Send button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSendReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
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
                      'Send Report via SMS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftsTab() {
    if (_draftReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.drafts_outlined,
              size: 48,
              color: AppColors.textGrey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No draft reports',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unsent reports will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _draftReports.length,
      itemBuilder: (context, index) {
        final report = _draftReports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(report.type),
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      report.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: report.isDraft ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  report.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textBlack,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Location: ${report.latitude.toStringAsFixed(4)} ${report.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (report.isDraft)
                      TextButton(
                        onPressed: () => _retryDraftReport(report),
                        child: const Text('Retry Send'),
                      ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _deleteDraftReport(report.id),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
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
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceButtons() {
    if (_selectedType == null) {
      return const SizedBox.shrink();
    }

    final incidentType = _stringToIncidentType(_selectedType ?? '');
    final choices = incidentChoices[incidentType] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select what happened *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...choices.map((choice) {
              final isSelected = _selectedChoice == choice;
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 40 - 12) / 2,
                child: OutlinedButton(
                  onPressed: () => _selectChoice(choice),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected
                        ? AppColors.primaryBlue
                        : Colors.transparent,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    choice,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textBlack,
                      height: 1.4,
                    ),
                  ),
                ),
              );
            }).toList(),
            SizedBox(
              width: (MediaQuery.of(context).size.width - 40 - 12) / 2,
              child: OutlinedButton(
                onPressed: _selectOthers,
                style: OutlinedButton.styleFrom(
                  backgroundColor: _showCustomField
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  side: BorderSide(
                    color: _showCustomField
                        ? AppColors.primaryBlue
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Others',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _showCustomField
                        ? Colors.white
                        : AppColors.textBlack,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_showCustomField) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _detailsController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Describe the incident...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
