import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/incident_model.dart';

abstract class ResponderRemoteDataSource {
  Future<PaginatedIncidentsModel> getAssignedIncidents({
    int page = 1,
    int limit = 10,
  });
  Future<IncidentModel> updateIncidentStatus(
    String id,
    String status, {
    String? notes,
  });
}

class ResponderRemoteDataSourceImpl implements ResponderRemoteDataSource {
  final DioClient _dioClient;

  ResponderRemoteDataSourceImpl(this._dioClient);

  @override
  Future<PaginatedIncidentsModel> getAssignedIncidents({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.assignedIncidents,
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedIncidentsModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<IncidentModel> updateIncidentStatus(
    String id,
    String status, {
    String? notes,
  }) async {
    final response = await _dioClient.patch(
      ApiConstants.incidentStatus(id),
      data: {
        'status': status,
        if (notes != null) 'notes': notes,
      },
    );
    final data = response.data as Map<String, dynamic>;
    // Server returns { message: "...", incident: {...} }
    final incidentData = data['incident'] as Map<String, dynamic>? ?? data;
    return IncidentModel.fromJson(incidentData);
  }
}

final responderRemoteDataSourceProvider =
    Provider<ResponderRemoteDataSource>((ref) {
  return ResponderRemoteDataSourceImpl(ref.watch(dioClientProvider));
});
