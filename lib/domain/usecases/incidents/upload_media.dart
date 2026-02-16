import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/incident_repository_impl.dart';
import '../../entities/media.dart';
import '../../repositories/incident_repository.dart';

class UploadMedia {
  final IncidentRepository _repository;

  UploadMedia(this._repository);

  Future<Either<Failure, Media>> call(String incidentId, String filePath) {
    return _repository.uploadMedia(incidentId, filePath);
  }
}

final uploadMediaProvider = Provider<UploadMedia>((ref) {
  return UploadMedia(ref.watch(incidentRepositoryProvider));
});
