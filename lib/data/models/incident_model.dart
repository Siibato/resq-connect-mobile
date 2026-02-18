import '../../domain/entities/incident.dart';

class IncidentModel {
  final String id;
  final String type;
  final String description;
  final double latitude;
  final double longitude;
  final String? address;
  final String status;
  final String? priority;
  final String? reporterName;
  final String? reporterMobile;
  final DateTime? createdAt;
  final List<IncidentMediaModel> media;

  const IncidentModel({
    required this.id,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.status,
    this.priority,
    this.reporterName,
    this.reporterMobile,
    this.createdAt,
    this.media = const [],
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase and snake_case from server
    final id = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    final latitude = (json['latitude'] as num?)?.toDouble() ??
                    (json['lat'] as num?)?.toDouble() ?? 0.0;
    final longitude = (json['longitude'] as num?)?.toDouble() ??
                     (json['lng'] as num?)?.toDouble() ??
                     (json['long'] as num?)?.toDouble() ?? 0.0;

    // Parse date from multiple possible field names
    DateTime? parsedDate;
    final dateFields = ['createdAt', 'created_at', 'timestamp', 'date'];
    for (final field in dateFields) {
      if (json[field] != null) {
        parsedDate = DateTime.tryParse(json[field].toString());
        if (parsedDate != null) break;
      }
    }

    // Extract reporter information
    String? reporterName;
    String? reporterMobile;
    final reporter = json['reporter'] as Map<String, dynamic>?;
    if (reporter != null) {
      reporterName = reporter['fullName']?.toString() ?? reporter['name']?.toString();
      reporterMobile = reporter['mobile']?.toString() ?? reporter['phone']?.toString();
    }

    return IncidentModel(
      id: id,
      type: json['type']?.toString().toUpperCase() ?? 'POLICE',
      description: json['description']?.toString() ?? '',
      latitude: latitude,
      longitude: longitude,
      address: json['address']?.toString(),
      status: json['status']?.toString().toUpperCase() ?? 'PENDING',
      priority: json['priority']?.toString(),
      reporterName: reporterName,
      reporterMobile: reporterMobile,
      createdAt: parsedDate ?? DateTime.now(),
      media: (json['media'] as List<dynamic>? ?? [])
          .map((m) => IncidentMediaModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
      'status': status,
      if (priority != null) 'priority': priority,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Incident toEntity({String? reporterName, String? reporterMobile}) {
    return Incident(
      id: id,
      type: IncidentTypeExtension.fromString(type),
      description: description,
      latitude: latitude,
      longitude: longitude,
      address: address,
      status: IncidentStatusExtension.fromString(status),
      priority: priority,
      reporterName: reporterName ?? this.reporterName,
      reporterMobile: reporterMobile ?? this.reporterMobile,
      createdAt: createdAt,
      mediaUrls: media.map((m) => m.fileUrl).toList(),
    );
  }
}

class IncidentMediaModel {
  final String id;
  final String fileUrl;
  final String fileType;

  const IncidentMediaModel({
    required this.id,
    required this.fileUrl,
    required this.fileType,
  });

  factory IncidentMediaModel.fromJson(Map<String, dynamic> json) {
    return IncidentMediaModel(
      id: json['id']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? json['file_url']?.toString() ?? '',
      fileType: json['fileType']?.toString() ?? json['file_type']?.toString() ?? 'image',
    );
  }
}

class CreateIncidentRequest {
  final String type;
  final String description;
  final double latitude;
  final double longitude;
  final String? address;

  const CreateIncidentRequest({
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
    };
  }
}

class PaginatedIncidentsModel {
  final List<IncidentModel> data;
  final int total;
  final int page;
  final int limit;

  const PaginatedIncidentsModel({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaginatedIncidentsModel.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return PaginatedIncidentsModel(
      data: dataList
          .map((item) => IncidentModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
    );
  }
}
