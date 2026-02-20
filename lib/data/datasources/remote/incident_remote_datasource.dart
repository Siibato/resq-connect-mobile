import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/incident_model.dart';

abstract class IncidentRemoteDataSource {
  Future<IncidentModel> createIncident(CreateIncidentRequest request);
  Future<PaginatedIncidentsModel> getMyReports({int page = 1, int limit = 10});
  Future<IncidentModel> getIncidentDetails(String id);
  Future<void> submitFeedback(String id, int rating, {String? feedback});
}

class IncidentRemoteDataSourceImpl implements IncidentRemoteDataSource {
  final DioClient _dioClient;

  IncidentRemoteDataSourceImpl(this._dioClient);

  @override
  Future<IncidentModel> createIncident(CreateIncidentRequest request) async {
    final response = await _dioClient.post(
      ApiConstants.createIncident,
      data: request.toJson(),
    );
    final incident = response.data['incident'] as Map<String, dynamic>;
    return IncidentModel.fromJson(incident);
  }

  @override
  Future<PaginatedIncidentsModel> getMyReports({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.myReports,
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedIncidentsModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<IncidentModel> getIncidentDetails(String id) async {
    final response = await _dioClient.get(ApiConstants.incidentDetail(id));
    return IncidentModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> submitFeedback(
    String id,
    int rating, {
    String? feedback,
  }) async {
    await _dioClient.post(
      ApiConstants.incidentFeedback(id),
      data: {
        'rating': rating,
        if (feedback != null) 'feedback': feedback,
      },
    );
  }
}

final incidentRemoteDataSourceProvider =
    Provider<IncidentRemoteDataSource>((ref) {
  return IncidentRemoteDataSourceImpl(ref.watch(dioClientProvider));
});
