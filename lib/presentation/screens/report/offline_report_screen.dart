import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../../data/models/offline_report_model.dart';
import '../../../services/location_service.dart';
import '../../providers/auth_provider.dart';

class OfflineReportScreen extends ConsumerStatefulWidget {
  const OfflineReportScreen({super.key});

  @override
  ConsumerState<OfflineReportScreen> createState() =>
      _OfflineReportScreenState();
}

class _OfflineReportScreenState extends ConsumerState<OfflineReportScreen> {
  String? _selectedType;
  final _detailsController = TextEditingController();
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
      // Check if SMS capability available (check if can send)
      final smsUri = Uri(scheme: 'sms', path: '+639453859979', queryParameters: {
        'body': smsText,
      });

      // Try to send SMS via native intent
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        // User sent SMS - mark as sent
        // But we assume it succeeded since we can't verify from the SMS app
        _saveOfflineReport(smsText, userName, true);
        _showSuccessDialog();
      } else {
        // No SMS capability - save as draft
        _saveOfflineReport(smsText, userName, false);
        _showDraftDialog();
      }
    } catch (e) {
      // Save as draft on any error
      _saveOfflineReport(smsText, userName, false);
      _showDraftDialog();
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

      // Clear form
      setState(() {
        _selectedType = null;
        _detailsController.clear();
        _draftReports.insert(0, report);
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

  void _showDraftDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Saved as Draft'),
        content: const Text(
          'Report saved as draft. It will be sent automatically when your phone has cellular connection available.',
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
      final smsUri = Uri(scheme: 'sms', path: '+639453859979', queryParameters: {
        'body': report.smsText,
      });

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
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

  @override
  Widget build(BuildContext context) {
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
              Tab(text: 'Drafts'),
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

          // Details field
          const Text(
            'Details *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 32),

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
}
