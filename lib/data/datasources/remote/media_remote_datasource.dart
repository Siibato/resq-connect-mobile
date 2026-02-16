import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/media_model.dart';

abstract class MediaRemoteDataSource {
  Future<MediaModel> uploadMedia(String incidentId, File file);
}

class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  final DioClient _dioClient;

  MediaRemoteDataSourceImpl(this._dioClient);

  @override
  Future<MediaModel> uploadMedia(String incidentId, File file) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'incidentId': incidentId,
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _dioClient.post(
      ApiConstants.mediaUpload,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return MediaModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final mediaRemoteDataSourceProvider = Provider<MediaRemoteDataSource>((ref) {
  return MediaRemoteDataSourceImpl(ref.watch(dioClientProvider));
});
