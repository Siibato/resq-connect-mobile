import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/incident.dart';
import '../../domain/usecases/responder/get_assigned_incidents.dart';
import '../../domain/usecases/responder/update_incident_status.dart';
import 'incident_provider.dart';

// --- Assigned Incidents State ---

sealed class AssignedIncidentsState {
  const AssignedIncidentsState();

  const factory AssignedIncidentsState.initial() = AssignedIncidentsInitial;
  const factory AssignedIncidentsState.loading() = AssignedIncidentsLoading;
  const factory AssignedIncidentsState.loaded(
    List<Incident> incidents, {
    Incident? newlyAssigned,
  }) = AssignedIncidentsLoaded;
  const factory AssignedIncidentsState.error(String message) =
      AssignedIncidentsError;

  bool get isLoading => this is AssignedIncidentsLoading;

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<Incident> incidents, Incident? newlyAssigned)? loaded,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    return switch (this) {
      AssignedIncidentsInitial() => initial?.call() ?? orElse(),
      AssignedIncidentsLoading() => loading?.call() ?? orElse(),
      AssignedIncidentsLoaded(incidents: final incidents, newlyAssigned: final newlyAssigned) =>
        loaded?.call(incidents, newlyAssigned) ?? orElse(),
      AssignedIncidentsError(message: final message) => error?.call(message) ?? orElse(),
    };
  }
}

class AssignedIncidentsInitial extends AssignedIncidentsState {
  const AssignedIncidentsInitial();
}

class AssignedIncidentsLoading extends AssignedIncidentsState {
  const AssignedIncidentsLoading();
}

class AssignedIncidentsLoaded extends AssignedIncidentsState {
  final List<Incident> incidents;
  final Incident? newlyAssigned;

  const AssignedIncidentsLoaded(
    this.incidents, {
    this.newlyAssigned,
  });
}

class AssignedIncidentsError extends AssignedIncidentsState {
  final String message;
  const AssignedIncidentsError(this.message);
}

final assignedIncidentsProvider = NotifierProvider<
    AssignedIncidentsNotifier,
    AssignedIncidentsState>(AssignedIncidentsNotifier.new);

class AssignedIncidentsNotifier extends Notifier<AssignedIncidentsState> {
  @override
  AssignedIncidentsState build() => const AssignedIncidentsState.initial();

  GetAssignedIncidents get _getAssignedIncidents =>
      ref.read(getAssignedIncidentsProvider);

  Future<void> load({int page = 1, int limit = 10}) async {
    state = const AssignedIncidentsState.loading();

    final result = await _getAssignedIncidents(page: page, limit: limit);

    result.fold(
      (failure) => state = AssignedIncidentsState.error(failure.message),
      (incidents) {
        // Check if we already have incidents loaded
        List<Incident> previousIncidents = [];
        if (state is AssignedIncidentsLoaded) {
          previousIncidents = (state as AssignedIncidentsLoaded).incidents;
        }

        // Detect new assignments by comparing incident IDs
        Incident? newlyAssigned;
        final previousIds = previousIncidents.map((i) => i.id).toSet();
        final currentIds = incidents.map((i) => i.id).toSet();

        final newIds = currentIds.difference(previousIds);
        if (newIds.isNotEmpty) {
          newlyAssigned = incidents.firstWhere((i) => newIds.contains(i.id));
        }

        state = AssignedIncidentsState.loaded(
          incidents,
          newlyAssigned: newlyAssigned,
        );
      },
    );
  }

  Future<void> refresh() => load(page: 1);
}

// --- Update Status State ---

sealed class UpdateStatusState {
  const UpdateStatusState();

  const factory UpdateStatusState.initial() = UpdateStatusInitial;
  const factory UpdateStatusState.loading() = UpdateStatusLoading;
  const factory UpdateStatusState.success(Incident incident) =
      UpdateStatusSuccess;
  const factory UpdateStatusState.error(String message) = UpdateStatusError;

  bool get isLoading => this is UpdateStatusLoading;
}

class UpdateStatusInitial extends UpdateStatusState {
  const UpdateStatusInitial();
}

class UpdateStatusLoading extends UpdateStatusState {
  const UpdateStatusLoading();
}

class UpdateStatusSuccess extends UpdateStatusState {
  final Incident incident;
  const UpdateStatusSuccess(this.incident);
}

class UpdateStatusError extends UpdateStatusState {
  final String message;
  const UpdateStatusError(this.message);
}

final updateStatusProvider =
    NotifierProvider<UpdateStatusNotifier, UpdateStatusState>(
  UpdateStatusNotifier.new,
);

class UpdateStatusNotifier extends Notifier<UpdateStatusState> {
  @override
  UpdateStatusState build() => const UpdateStatusState.initial();

  UpdateIncidentStatus get _updateIncidentStatus =>
      ref.read(updateIncidentStatusProvider);

  Future<void> update(
    String incidentId,
    String status, {
    String? notes,
  }) async {
    state = const UpdateStatusState.loading();

    final result = await _updateIncidentStatus(
      UpdateIncidentStatusParams(
        incidentId: incidentId,
        status: status,
        notes: notes,
      ),
    );

    result.fold(
      (failure) => state = UpdateStatusState.error(failure.message),
      (incident) {
        state = UpdateStatusState.success(incident);
        // Refresh the assigned incidents list and incident details after status update
        ref.read(assignedIncidentsProvider.notifier).refresh();
        // Also invalidate and reload the incident details
        ref.invalidate(incidentDetailsProvider(incidentId));
      },
    );
  }

  void reset() {
    state = const UpdateStatusState.initial();
  }
}
