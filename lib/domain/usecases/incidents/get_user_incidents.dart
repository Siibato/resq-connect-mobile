import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/incident_repository_impl.dart';
import '../../entities/incident.dart';
import '../../repositories/incident_repository.dart';

class GetUserIncidents {
  final IncidentRepository _repository;

  GetUserIncidents(this._repository);

  Future<Either<Failure, List<Incident>>> call({
    int page = 1,
    int limit = 10,
  }) {
    return _repository.getMyReports(page: page, limit: limit);
  }
}

final getUserIncidentsProvider = Provider<GetUserIncidents>((ref) {
  return GetUserIncidents(ref.watch(incidentRepositoryProvider));
});
