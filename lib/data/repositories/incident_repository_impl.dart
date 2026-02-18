import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/incident.dart';
import '../../domain/entities/media.dart';
import '../../domain/repositories/incident_repository.dart';
import '../datasources/local/database_helper.dart';
import '../datasources/remote/incident_remote_datasource.dart';
import '../datasources/remote/media_remote_datasource.dart';
import '../datasources/remote/responder_remote_datasource.dart';
import '../models/incident_model.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentRemoteDataSource _remoteDataSource;
  final MediaRemoteDataSource _mediaDataSource;
  final ResponderRemoteDataSource _responderDataSource;
  final DatabaseHelper _databaseHelper;

  IncidentRepositoryImpl({
    required IncidentRemoteDataSource remoteDataSource,
    required MediaRemoteDataSource mediaDataSource,
    required ResponderRemoteDataSource responderDataSource,
    required DatabaseHelper databaseHelper,
  })  : _remoteDataSource = remoteDataSource,
        _mediaDataSource = mediaDataSource,
        _responderDataSource = responderDataSource,
        _databaseHelper = databaseHelper;

  @override
  Future<Either<Failure, Incident>> createIncident({
    required IncidentType type,
    required String description,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      final model = await _remoteDataSource.createIncident(
        CreateIncidentRequest(
          type: type.serverValue,
          description: description,
          latitude: latitude,
          longitude: longitude,
          address: address,
        ),
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Incident>>> getMyReports({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await _remoteDataSource.getMyReports(
        page: page,
        limit: limit,
      );
      final incidents = result.data.map((m) => m.toEntity()).toList();
      return Right(incidents);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Incident>> getIncidentDetails(String id) async {
    try {
      final model = await _remoteDataSource.getIncidentDetails(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Media>> uploadMedia(
    String incidentId,
    String filePath,
  ) async {
    try {
      final file = File(filePath);
      final model = await _mediaDataSource.uploadMedia(incidentId, file);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitFeedback(
    String id,
    int rating, {
    String? feedback,
  }) async {
    try {
      await _remoteDataSource.submitFeedback(id, rating, feedback: feedback);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> queueOfflineReport({
    required IncidentType type,
    required String description,
    required double latitude,
    required double longitude,
    String? address,
    String? mediaPath,
  }) async {
    try {
      await _databaseHelper.insertOfflineReport({
        'type': type.serverValue,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'media_path': mediaPath,
        'created_at': DateTime.now().toIso8601String(),
      });
      return const Right(null);
    } catch (e) {
      return Left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> syncOfflineReports() async {
    try {
      final pending = await _databaseHelper.getPendingOfflineReports();
      int synced = 0;

      for (final report in pending) {
        try {
          await _remoteDataSource.createIncident(
            CreateIncidentRequest(
              type: report['type'] as String,
              description: report['description'] as String,
              latitude: report['latitude'] as double,
              longitude: report['longitude'] as double,
              address: report['address'] as String?,
            ),
          );
          await _databaseHelper.markReportSynced(report['id'] as int);
          synced++;
        } catch (_) {
          // Skip failed items, retry on next sync
        }
      }

      return Right(synced);
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Incident>>> getAssignedIncidents(
    int page,
    int limit,
  ) async {
    try {
      final result = await _responderDataSource.getAssignedIncidents(
        page: page,
        limit: limit,
      );
      final incidents = result.data.map((m) => m.toEntity()).toList();
      return Right(incidents);
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Incident>> updateIncidentStatus(
    String id,
    String status, {
    String? notes,
  }) async {
    try {
      final model = await _responderDataSource.updateIncidentStatus(
        id,
        status,
        notes: notes,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }
}

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  return IncidentRepositoryImpl(
    remoteDataSource: ref.watch(incidentRemoteDataSourceProvider),
    mediaDataSource: ref.watch(mediaRemoteDataSourceProvider),
    responderDataSource: ref.watch(responderRemoteDataSourceProvider),
    databaseHelper: ref.watch(databaseHelperProvider),
  );
});
