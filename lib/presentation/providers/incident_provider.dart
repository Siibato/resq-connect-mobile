import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/incident.dart';
import '../../domain/usecases/incidents/create_incident.dart';
import '../../domain/usecases/incidents/get_incident_details.dart';
import '../../domain/usecases/incidents/get_user_incidents.dart';
import '../../domain/usecases/incidents/upload_media.dart';

// --- Submission state ---

sealed class IncidentSubmitState {
  const IncidentSubmitState();

  const factory IncidentSubmitState.initial() = IncidentSubmitInitial;
  const factory IncidentSubmitState.loading() = IncidentSubmitLoading;
  const factory IncidentSubmitState.success(Incident incident) =
      IncidentSubmitSuccess;
  const factory IncidentSubmitState.error(String message) =
      IncidentSubmitError;

  bool get isLoading => this is IncidentSubmitLoading;
}

class IncidentSubmitInitial extends IncidentSubmitState {
  const IncidentSubmitInitial();
}

class IncidentSubmitLoading extends IncidentSubmitState {
  const IncidentSubmitLoading();
}

class IncidentSubmitSuccess extends IncidentSubmitState {
  final Incident incident;
  const IncidentSubmitSuccess(this.incident);
}

class IncidentSubmitError extends IncidentSubmitState {
  final String message;
  const IncidentSubmitError(this.message);
}

final incidentSubmitProvider =
    NotifierProvider<IncidentSubmitNotifier, IncidentSubmitState>(
  IncidentSubmitNotifier.new,
);

class IncidentSubmitNotifier extends Notifier<IncidentSubmitState> {
  late final Logger _logger = Logger();

  @override
  IncidentSubmitState build() => const IncidentSubmitState.initial();

  CreateIncident get _createIncident => ref.read(createIncidentProvider);
  UploadMedia get _uploadMedia => ref.read(uploadMediaProvider);

  Future<void> submit({
    required IncidentType type,
    required String description,
    required double latitude,
    required double longitude,
    String? address,
    String? mediaPath,
  }) async {
    state = const IncidentSubmitState.loading();

    final result = await _createIncident(CreateIncidentParams(
      type: type,
      description: description,
      latitude: latitude,
      longitude: longitude,
      address: address,
    ));

    await result.fold(
      (failure) async {
        state = IncidentSubmitState.error(failure.message);
      },
      (incident) async {
        // Upload media if provided
        if (mediaPath != null) {
          final uploadResult = await _uploadMedia(incident.id, mediaPath);

          uploadResult.fold(
            (failure) {
              // Log media upload failure but don't fail the entire incident
              // The incident was successfully created, just media upload had issues
              _logger.w('Media upload failed: ${failure.message}');
            },
            (media) {
              // Media uploaded successfully
              _logger.i('Media uploaded successfully: ${media.id}');
            },
          );
        }
        state = IncidentSubmitState.success(incident);
      },
    );
  }

  void reset() {
    state = const IncidentSubmitState.initial();
  }
}

// --- Report history state ---

sealed class MyReportsState {
  const MyReportsState();

  const factory MyReportsState.initial() = MyReportsInitial;
  const factory MyReportsState.loading() = MyReportsLoading;
  const factory MyReportsState.loaded(List<Incident> incidents) =
      MyReportsLoaded;
  const factory MyReportsState.error(String message) = MyReportsError;
}

class MyReportsInitial extends MyReportsState {
  const MyReportsInitial();
}

class MyReportsLoading extends MyReportsState {
  const MyReportsLoading();
}

class MyReportsLoaded extends MyReportsState {
  final List<Incident> incidents;
  const MyReportsLoaded(this.incidents);
}

class MyReportsError extends MyReportsState {
  final String message;
  const MyReportsError(this.message);
}

final myReportsProvider =
    NotifierProvider<MyReportsNotifier, MyReportsState>(
  MyReportsNotifier.new,
);

class MyReportsNotifier extends Notifier<MyReportsState> {
  @override
  MyReportsState build() => const MyReportsState.initial();

  GetUserIncidents get _getUserIncidents => ref.read(getUserIncidentsProvider);

  Future<void> load() async {
    state = const MyReportsState.loading();
    final result = await _getUserIncidents();
    result.fold(
      (failure) => state = MyReportsState.error(failure.message),
      (incidents) => state = MyReportsState.loaded(incidents),
    );
  }
}

// --- Incident details state ---

sealed class IncidentDetailsState {
  const IncidentDetailsState();

  const factory IncidentDetailsState.initial() = IncidentDetailsInitial;
  const factory IncidentDetailsState.loading() = IncidentDetailsLoading;
  const factory IncidentDetailsState.loaded(Incident incident) =
      IncidentDetailsLoaded;
  const factory IncidentDetailsState.error(String message) =
      IncidentDetailsError;

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(Incident incident)? loaded,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    return switch (this) {
      IncidentDetailsInitial() => initial?.call() ?? orElse(),
      IncidentDetailsLoading() => loading?.call() ?? orElse(),
      IncidentDetailsLoaded(incident: final incident) =>
        loaded?.call(incident) ?? orElse(),
      IncidentDetailsError(message: final message) =>
        error?.call(message) ?? orElse(),
    };
  }
}

class IncidentDetailsInitial extends IncidentDetailsState {
  const IncidentDetailsInitial();
}

class IncidentDetailsLoading extends IncidentDetailsState {
  const IncidentDetailsLoading();
}

class IncidentDetailsLoaded extends IncidentDetailsState {
  final Incident incident;
  const IncidentDetailsLoaded(this.incident);
}

class IncidentDetailsError extends IncidentDetailsState {
  final String message;
  const IncidentDetailsError(this.message);
}

final incidentDetailsProvider = NotifierProvider.family<
    IncidentDetailsNotifier, IncidentDetailsState, String>(
  IncidentDetailsNotifier.new,
);

class IncidentDetailsNotifier
    extends FamilyNotifier<IncidentDetailsState, String> {
  @override
  IncidentDetailsState build(String arg) {
    Future.microtask(() => load(arg));
    return const IncidentDetailsState.loading();
  }

  GetIncidentDetails get _getDetails => ref.read(getIncidentDetailsProvider);

  Future<void> load(String id) async {
    state = const IncidentDetailsState.loading();
    final result = await _getDetails(id);
    result.fold(
      (failure) => state = IncidentDetailsState.error(failure.message),
      (incident) => state = IncidentDetailsState.loaded(incident),
    );
  }

  void updateIncident(Incident incident) {
    state = IncidentDetailsState.loaded(incident);
  }
}
