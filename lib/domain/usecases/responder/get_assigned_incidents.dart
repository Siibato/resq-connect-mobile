import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/incident_repository_impl.dart';
import '../../entities/incident.dart';
import '../../repositories/incident_repository.dart';

class GetAssignedIncidents {
  final IncidentRepository _repository;

  GetAssignedIncidents(this._repository);

  Future<Either<Failure, List<Incident>>> call({
    int page = 1,
    int limit = 10,
  }) {
    return _repository.getAssignedIncidents(page, limit);
  }
}

final getAssignedIncidentsProvider = Provider<GetAssignedIncidents>((ref) {
  return GetAssignedIncidents(ref.watch(incidentRepositoryProvider));
});
