import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/incident.dart';
import '../../../services/health_check_service.dart';
import '../../../services/location_service.dart';
import '../../../services/camera_service.dart';
import '../../providers/incident_provider.dart';
import 'offline_report_screen.dart';
import 'report_confirmation_screen.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen> {
  final _descriptionController = TextEditingController();
  final _locationService = LocationService();
  final _cameraService = CameraService();

  IncidentType? _selectedType;
  String? _mediaPath;
  String _addressText = 'Fetching location...';
  double _latitude = 0;
  double _longitude = 0;
  bool _locationLoaded = false;
  final MapController _mapController = MapController();
  VideoPlayerController? _videoController;

  final _categoryLabels = {
    IncidentType.police: 'Police',
    IncidentType.medical: 'CDRRMO (Rescue)',
    IncidentType.fire: 'Fire Protection',
  };

  @override
  void initState() {
    super.initState();
    _checkServerAndFetchLocation();
  }

  Future<void> _checkServerAndFetchLocation() async {
    // For access to ref, we need to use context to get the WidgetRef
    final healthCheckService = ref.read(healthCheckServiceProvider);
    final isServerReachable = await healthCheckService.isServerReachable();

    if (!isServerReachable && mounted) {
      // Server not reachable - go to offline mode
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OfflineReportScreen()),
      );
      return;
    }

    // Server reachable - proceed with normal flow
    _fetchLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _mapController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _addressText =
            _locationService.getAddressFromCoordinates(_latitude, _longitude);
        _locationLoaded = true;
      });

      // Move map to current location
      await Future.delayed(const Duration(milliseconds: 300));
      _mapController.move(LatLng(_latitude, _longitude), 15.0);
    } catch (e) {
      setState(() {
        _addressText = 'Unable to get location';
      });
    }
  }

  Future<void> _pickPhoto() async {
    final file = await _cameraService.pickImageFromCamera();
    if (file != null) {
      setState(() {
        _mediaPath = file.path;
        _videoController = null; // Clear video controller
      });
    }
  }

  Future<void> _pickVideo() async {
    final file = await _cameraService.recordVideo();
    if (file != null) {
      setState(() {
        _mediaPath = file.path;
        // Initialize video controller
        _videoController = VideoPlayerController.file(File(file.path))
          ..initialize().then((_) {
            setState(() {});
          });
      });
    }
  }

  bool _isVideoFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
  }

  void _submitReport() {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    if (_descriptionController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description must be at least 10 characters'),
        ),
      );
      return;
    }

    ref.read(incidentSubmitProvider.notifier).submit(
          type: _selectedType!,
          description: _descriptionController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          address: _addressText != 'Unable to get location' &&
                  _addressText != 'Fetching location...'
              ? _addressText
              : null,
          mediaPath: _mediaPath,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<IncidentSubmitState>(incidentSubmitProvider, (previous, next) {
      if (next is IncidentSubmitSuccess) {
        ref.read(incidentSubmitProvider.notifier).reset();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                ReportConfirmationScreen(incident: next.incident),
          ),
        );
      } else if (next is IncidentSubmitError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    final submitState = ref.watch(incidentSubmitProvider);
    final isLoading = submitState.isLoading;

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
          'Send your report',
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
            // Choose Location
            const Text(
              'Choose Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              clipBehavior: Clip.antiAlias,
              child: _locationLoaded
                  ? FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(_latitude, _longitude),
                        initialZoom: 15.0,
                        onTap: (tapPosition, latLng) {
                          setState(() {
                            _latitude = latLng.latitude;
                            _longitude = latLng.longitude;
                            _addressText =
                                _locationService.getAddressFromCoordinates(
                              _latitude,
                              _longitude,
                            );
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.mobile',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(_latitude, _longitude),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: AppColors.primaryBlue,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _fetchLocation,
              icon: const Icon(Icons.my_location, size: 18),
              label: const Text('Change pin location'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
            Text(
              _addressText,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 24),

            // Open Camera
            const Text(
              'Open your camera',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _mediaPath != null && !_mediaPath!.endsWith('.mp4') && !_mediaPath!.endsWith('.mov') && !_mediaPath!.endsWith('.avi')
                            ? AppColors.primaryBlue
                            : AppColors.textGrey,
                        side: BorderSide(
                          color: _mediaPath != null && !_mediaPath!.endsWith('.mp4') && !_mediaPath!.endsWith('.mov') && !_mediaPath!.endsWith('.avi')
                              ? AppColors.primaryBlue
                              : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.videocam),
                      label: const Text('Video'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _mediaPath != null && (_mediaPath!.endsWith('.mp4') || _mediaPath!.endsWith('.mov') || _mediaPath!.endsWith('.avi'))
                            ? AppColors.primaryBlue
                            : AppColors.textGrey,
                        side: BorderSide(
                          color: _mediaPath != null && (_mediaPath!.endsWith('.mp4') || _mediaPath!.endsWith('.mov') || _mediaPath!.endsWith('.avi'))
                              ? AppColors.primaryBlue
                              : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_mediaPath != null) ...[
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryBlue, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_isVideoFile(_mediaPath!))
                      _videoController != null && _videoController!.value.isInitialized
                          ? VideoPlayer(_videoController!)
                          : const Center(child: CircularProgressIndicator())
                    else
                      Image.file(
                        File(_mediaPath!),
                        fit: BoxFit.cover,
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            _videoController?.dispose();
                            setState(() {
                              _mediaPath = null;
                              _videoController = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
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
              maxLines: 5,
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

            // Submit
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: isLoading
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
                        'Submit Report',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
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
