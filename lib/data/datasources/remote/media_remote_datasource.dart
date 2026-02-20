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
    // Step 1: Get Cloudinary upload signature from server
    final signResponse = await _dioClient.get(ApiConstants.mediaSign);
    final sig = signResponse.data as Map<String, dynamic>;

    // Step 2: Upload directly to Cloudinary (bypasses Vercel)
    final fileName = file.path.split('/').last;
    final fileType = _isVideo(fileName) ? 'video' : 'image';
    final cloudinaryUrl = 'https://api.cloudinary.com/v1_1/${sig['cloudName']}/$fileType/upload';

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
      'api_key': sig['apiKey'],
      'timestamp': sig['timestamp'].toString(),
      'signature': sig['signature'],
      'folder': sig['folder'],
    });

    // Use raw Dio instance to avoid interceptors/auth headers
    final cloudinaryResponse = await Dio().post(
      cloudinaryUrl,
      data: formData,
    );

    if (cloudinaryResponse.statusCode != 200) {
      throw Exception('Cloudinary upload failed: ${cloudinaryResponse.statusCode}');
    }

    final secureUrl = cloudinaryResponse.data['secure_url'] as String;

    // Step 3: Confirm upload with server (saves to incident_media DB)
    final confirmResponse = await _dioClient.post(
      ApiConstants.mediaConfirm,
      data: {
        'incidentId': incidentId,
        'fileUrl': secureUrl,
        'fileType': fileType,
      },
    );

    return MediaModel.fromJson(confirmResponse.data['media'] as Map<String, dynamic>);
  }

  bool _isVideo(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
  }
}

final mediaRemoteDataSourceProvider = Provider<MediaRemoteDataSource>((ref) {
  return MediaRemoteDataSourceImpl(ref.watch(dioClientProvider));
});
