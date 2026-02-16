import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/incident_repository_impl.dart';
import '../../entities/incident.dart';
import '../../repositories/incident_repository.dart';

class SubmitOfflineReportParams {
  final IncidentType type;
  final String description;
  final double latitude;
  final double longitude;
  final String? address;
  final String? mediaPath;

  const SubmitOfflineReportParams({
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    this.mediaPath,
  });
}

class SubmitOfflineReport {
  final IncidentRepository _repository;

  SubmitOfflineReport(this._repository);

  Future<Either<Failure, void>> call(SubmitOfflineReportParams params) {
    return _repository.queueOfflineReport(
      type: params.type,
      description: params.description,
      latitude: params.latitude,
      longitude: params.longitude,
      address: params.address,
      mediaPath: params.mediaPath,
    );
  }
}

class SyncOfflineReports {
  final IncidentRepository _repository;

  SyncOfflineReports(this._repository);

  Future<Either<Failure, int>> call() {
    return _repository.syncOfflineReports();
  }
}

final submitOfflineReportProvider = Provider<SubmitOfflineReport>((ref) {
  return SubmitOfflineReport(ref.watch(incidentRepositoryProvider));
});

final syncOfflineReportsProvider = Provider<SyncOfflineReports>((ref) {
  return SyncOfflineReports(ref.watch(incidentRepositoryProvider));
});
