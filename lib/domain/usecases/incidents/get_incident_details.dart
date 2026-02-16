import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/incident_repository_impl.dart';
import '../../entities/incident.dart';
import '../../repositories/incident_repository.dart';

class GetIncidentDetails {
  final IncidentRepository _repository;

  GetIncidentDetails(this._repository);

  Future<Either<Failure, Incident>> call(String id) {
    return _repository.getIncidentDetails(id);
  }
}

final getIncidentDetailsProvider = Provider<GetIncidentDetails>((ref) {
  return GetIncidentDetails(ref.watch(incidentRepositoryProvider));
});
