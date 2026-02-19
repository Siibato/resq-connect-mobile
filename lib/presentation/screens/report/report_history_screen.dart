import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/incident.dart';
import '../../providers/incident_provider.dart';
import 'report_details_screen.dart';

class ReportHistoryScreen extends ConsumerStatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  ConsumerState<ReportHistoryScreen> createState() =>
      _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends ConsumerState<ReportHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(myReportsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Reports',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: switch (state) {
        MyReportsInitial() || MyReportsLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        MyReportsError(message: final msg) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg, style: const TextStyle(color: AppColors.textGrey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(myReportsProvider.notifier).load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        MyReportsLoaded(incidents: final incidents) => incidents.isEmpty
            ? const Center(
                child: Text(
                  'No reports yet.',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(myReportsProvider.notifier).load(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: incidents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final incident = incidents[index];
                    return _IncidentCard(
                      incident: incident,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ReportDetailsScreen(incidentId: incident.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
      },
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback onTap;

  const _IncidentCard({required this.incident, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconForType(incident.type),
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    incident.type.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    incident.displayLocation,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (incident.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(incident.createdAt!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _StatusBadge(status: incident.status),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(IncidentType type) {
    switch (type) {
      case IncidentType.fire:
        return Icons.local_fire_department_outlined;
      case IncidentType.medical:
        return Icons.medical_services_outlined;
      case IncidentType.police:
        return Icons.local_police_outlined;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final IncidentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case IncidentStatus.pending:
        color = AppColors.statusReceived;
      case IncidentStatus.acknowledged:
      case IncidentStatus.inProgress:
        color = AppColors.statusInProgress;
      case IncidentStatus.resolved:
        color = AppColors.statusResolved;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
