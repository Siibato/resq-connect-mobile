import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/incident.dart';
import '../../../services/location_service.dart';
import '../../../services/sms_service.dart';

// Configure the SMS gateway number via environment or constants
const _smsGatewayNumber = '+639000000000'; // Replace with actual number

class OfflineModeScreen extends ConsumerStatefulWidget {
  const OfflineModeScreen({super.key});

  @override
  ConsumerState<OfflineModeScreen> createState() => _OfflineModeScreenState();
}

class _OfflineModeScreenState extends ConsumerState<OfflineModeScreen> {
  final _descriptionController = TextEditingController();
  final _locationService = LocationService();

  IncidentType? _selectedType;
  double _latitude = 0;
  double _longitude = 0;
  bool _locationLoaded = false;
  bool _sending = false;

  final _categoryLabels = {
    IncidentType.police: 'Police',
    IncidentType.medical: 'CDRRMO (Rescue)',
    IncidentType.fire: 'Fire Protection',
  };

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationLoaded = true;
      });
    } catch (_) {}
  }

  Future<void> _sendSms() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe what happened')),
      );
      return;
    }
    if (!_locationLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for location...')),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      final smsService = ref.read(smsServiceProvider);
      await smsService.sendReport(
        gatewayNumber: _smsGatewayNumber,
        type: _selectedType!,
        latitude: _latitude,
        longitude: _longitude,
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS report sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send SMS: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

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
        title: const Text(
          'SMS Report',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You are offline. Your report will be sent via SMS.',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Location status
            Row(
              children: [
                Icon(
                  _locationLoaded ? Icons.location_on : Icons.location_off,
                  color: _locationLoaded ? Colors.green : AppColors.textGrey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _locationLoaded
                      ? 'Location: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}'
                      : 'Getting location...',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Category
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<IncidentType>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                hintText: 'Select category',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              items: IncidentType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_categoryLabels[type]!),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value),
            ),
            const SizedBox(height: 24),

            // Description
            const Text(
              'Tell us what happened',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the incident...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _sendSms,
                icon: _sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.sms_outlined),
                label: Text(
                  _sending ? 'Sending...' : 'Send via SMS',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
