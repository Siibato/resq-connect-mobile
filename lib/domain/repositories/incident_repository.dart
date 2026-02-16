import 'package:fpdart/fpdart.dart';

import '../entities/incident.dart';
import '../entities/media.dart';
import '../../core/errors/failures.dart';

abstract class IncidentRepository {
  Future<Either<Failure, Incident>> createIncident({
    required IncidentType type,
    required String description,
    required double latitude,
    required double longitude,
    String? address,
  });

  Future<Either<Failure, List<Incident>>> getMyReports({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, Incident>> getIncidentDetails(String id);

  Future<Either<Failure, Media>> uploadMedia(String incidentId, String filePath);

  Future<Either<Failure, void>> submitFeedback(
    String id,
    int rating, {
    String? feedback,
  });

  Future<Either<Failure, void>> queueOfflineReport({
    required IncidentType type,
    required String description,
    required double latitude,
    required double longitude,
    String? address,
    String? mediaPath,
  });

  Future<Either<Failure, int>> syncOfflineReports();
}
