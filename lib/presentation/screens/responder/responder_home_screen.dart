import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/incident.dart';
import '../../../services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/responder_provider.dart';
import '../../widgets/incident/incident_card.dart';
import '../account/account_screen.dart';
import '../emergency/emergency_screen.dart';
import 'report_assignment_modal.dart';
import 'responder_report_details_screen.dart';

class ResponderHomeScreen extends ConsumerStatefulWidget {
  const ResponderHomeScreen({super.key});

  @override
  ConsumerState<ResponderHomeScreen> createState() => _ResponderHomeScreenState();
}

class _ResponderHomeScreenState extends ConsumerState<ResponderHomeScreen> {
  int _currentIndex = 0;
  Timer? _pollingTimer;
  bool _shownModal = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _startPolling();
  }

  void _loadInitialData() {
    Future.microtask(() {
      ref.read(assignedIncidentsProvider.notifier).load();
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted) {
          ref.read(assignedIncidentsProvider.notifier).load();
        }
      },
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _showAssignmentModal(BuildContext context, incident) {
    if (_shownModal) return;
    _shownModal = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ReportAssignmentModal(
        incident: incident,
        onAccept: () {
          Navigator.pop(context);
          _shownModal = false;
          // Status will be updated and details screen will open from modal
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AssignedIncidentsState>(
      assignedIncidentsProvider,
      (previous, next) {
        next.maybeWhen(
          loaded: (incidents, newlyAssigned) {
            // Only show modal if incident is PENDING (Received status)
            // Never show for ACKNOWLEDGED, IN_PROGRESS, or RESOLVED
            if (newlyAssigned != null && newlyAssigned.status == IncidentStatus.pending) {
              // Show system notification
              ref.read(notificationServiceProvider).showNotification(
                title: 'New Incident Assigned',
                body:
                    '${newlyAssigned.type.displayName} at ${newlyAssigned.displayLocation}',
              );
              _showAssignmentModal(context, newlyAssigned);
            }
          },
          orElse: () {},
        );
      },
    );

    final authState = ref.watch(authNotifierProvider);

    return authState.maybeWhen(
      authenticated: (user) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildAssignedIncidentsTab(user),
              const EmergencyScreen(),
              const AccountScreen(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textGrey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_outlined),
              activeIcon: Icon(Icons.warning_amber),
              label: 'Emergency',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'My profile',
            ),
          ],
        ),
      ),
      orElse: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildAssignedIncidentsTab(user) {
    final assignedIncidentsState = ref.watch(assignedIncidentsProvider);

    return assignedIncidentsState.maybeWhen(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (message) => Center(
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
              'Error loading incidents',
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
      loaded: (incidents, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Search bar and notification
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 16),
                          Icon(Icons.search, color: AppColors.textGrey),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Welcome greeting
              Text(
                'Welcome, ${user.fullName.split(' ').first}!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              // Department badge
              if (user.department != null)
                Chip(
                  label: Text(
                    user.department!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.primaryBlue,
                ),
              const SizedBox(height: 20),
              // Incidents list or empty state
              if (incidents.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 64,
                          color: AppColors.textGrey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No assigned reports',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You\'ll see assigned incidents here',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () =>
                        ref.read(assignedIncidentsProvider.notifier).refresh(),
                    child: ListView.builder(
                      itemCount: incidents.length,
                      itemBuilder: (context, index) {
                        final incident = incidents[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ResponderReportDetailsScreen(
                                    incidentId: incident.id,
                                  ),
                                ),
                              );
                            },
                            child: IncidentCard(incident: incident),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      orElse: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Search bar and notification
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.search, color: AppColors.textGrey),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Welcome greeting
            Text(
              'Welcome, ${user.fullName.split(' ').first}!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 8),
            // Department badge
            if (user.department != null)
              Chip(
                label: Text(
                  user.department!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.primaryBlue,
              ),
            const SizedBox(height: 20),
            // Loading state
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      'Loading incidents...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
