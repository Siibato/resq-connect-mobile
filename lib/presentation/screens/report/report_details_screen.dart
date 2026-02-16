import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/incident.dart';
import '../../providers/incident_provider.dart';

class ReportDetailsScreen extends ConsumerWidget {
  final String incidentId;

  const ReportDetailsScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(incidentDetailsProvider(incidentId));

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
          'Report Details',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: switch (state) {
        IncidentDetailsInitial() || IncidentDetailsLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        IncidentDetailsError(message: final msg) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg, style: const TextStyle(color: AppColors.textGrey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(incidentDetailsProvider(incidentId).notifier)
                      .load(incidentId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        IncidentDetailsLoaded(incident: final incident) =>
          _DetailsBody(incident: incident),
      },
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final Incident incident;

  const _DetailsBody({required this.incident});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(incident.latitude, incident.longitude),
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mobile',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(incident.latitude, incident.longitude),
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
            ),
          ),
          const SizedBox(height: 24),

          // Info rows
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: incident.displayLocation,
          ),
          const Divider(height: 32),
          _InfoRow(
            icon: Icons.warning_amber_outlined,
            label: 'Category',
            value: incident.type.displayName,
          ),
          const Divider(height: 32),
          _InfoRow(
            icon: Icons.edit_outlined,
            label: 'Description',
            value: incident.description,
          ),
          if (incident.createdAt != null) ...[
            const Divider(height: 32),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Date Reported',
              value: DateFormat('MMMM dd, yyyy – hh:mm a')
                  .format(incident.createdAt!),
            ),
          ],
          const SizedBox(height: 24),

          // Status
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 12),
          _StatusTimeline(status: incident.status),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _StatusTimeline extends StatelessWidget {
  final IncidentStatus status;

  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (IncidentStatus.pending, 'Received', Icons.inbox_outlined),
      (IncidentStatus.acknowledged, 'Acknowledged', Icons.visibility_outlined),
      (IncidentStatus.inProgress, 'In Progress', Icons.directions_run),
      (IncidentStatus.resolved, 'Resolved', Icons.check_circle_outline),
    ];

    final currentIndex = steps.indexWhere((s) => s.$1 == status);

    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final (_, label, icon) = entry.value;
        final isDone = i <= currentIndex;

        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        isDone ? AppColors.primaryBlue : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isDone ? Colors.white : AppColors.textGrey,
                  ),
                ),
                if (i < steps.length - 1)
                  Container(
                    width: 2,
                    height: 24,
                    color: isDone && i < currentIndex
                        ? AppColors.primaryBlue
                        : Colors.grey.shade200,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isDone ? FontWeight.w600 : FontWeight.normal,
                  color: isDone ? AppColors.textBlack : AppColors.textGrey,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
