import '../../domain/entities/media.dart';

class MediaModel {
  final String id;
  final String incidentId;
  final String fileUrl;
  final String fileType;
  final DateTime? createdAt;

  const MediaModel({
    required this.id,
    required this.incidentId,
    required this.fileUrl,
    required this.fileType,
    this.createdAt,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as String,
      incidentId: json['incidentId'] as String,
      fileUrl: json['fileUrl'] as String,
      fileType: json['fileType'] as String? ?? 'image',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Media toEntity() {
    return Media(
      id: id,
      incidentId: incidentId,
      fileUrl: fileUrl,
      fileType: fileType,
      createdAt: createdAt,
    );
  }
}
