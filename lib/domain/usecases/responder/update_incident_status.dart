import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/incident_repository_impl.dart';
import '../../entities/incident.dart';
import '../../repositories/incident_repository.dart';

class UpdateIncidentStatusParams {
  final String incidentId;
  final String status;
  final String? notes;

  const UpdateIncidentStatusParams({
    required this.incidentId,
    required this.status,
    this.notes,
  });
}

class UpdateIncidentStatus {
  final IncidentRepository _repository;

  UpdateIncidentStatus(this._repository);

  Future<Either<Failure, Incident>> call(UpdateIncidentStatusParams params) {
    return _repository.updateIncidentStatus(
      params.incidentId,
      params.status,
      notes: params.notes,
    );
  }
}

final updateIncidentStatusProvider = Provider<UpdateIncidentStatus>((ref) {
  return UpdateIncidentStatus(ref.watch(incidentRepositoryProvider));
});
