import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/incident_repository_impl.dart';
import '../../entities/incident.dart';
import '../../repositories/incident_repository.dart';

class CreateIncidentParams {
  final IncidentType type;
  final String description;
  final double latitude;
  final double longitude;
  final String? address;

  const CreateIncidentParams({
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

class CreateIncident {
  final IncidentRepository _repository;

  CreateIncident(this._repository);

  Future<Either<Failure, Incident>> call(CreateIncidentParams params) {
    return _repository.createIncident(
      type: params.type,
      description: params.description,
      latitude: params.latitude,
      longitude: params.longitude,
      address: params.address,
    );
  }
}

final createIncidentProvider = Provider<CreateIncident>((ref) {
  return CreateIncident(ref.watch(incidentRepositoryProvider));
});
