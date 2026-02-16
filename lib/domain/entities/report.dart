enum ReportStatus { received, inProgress, resolved, closed }

class Report {
  final String id;
  final String location;
  final double latitude;
  final double longitude;
  final String category;
  final String description;
  final String? mediaPath;
  final String reporterName;
  final DateTime dateReported;
  final ReportStatus status;

  const Report({
    required this.id,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.description,
    this.mediaPath,
    required this.reporterName,
    required this.dateReported,
    this.status = ReportStatus.received,
  });

  Report copyWith({
    String? id,
    String? location,
    double? latitude,
    double? longitude,
    String? category,
    String? description,
    String? mediaPath,
    String? reporterName,
    DateTime? dateReported,
    ReportStatus? status,
  }) {
    return Report(
      id: id ?? this.id,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      description: description ?? this.description,
      mediaPath: mediaPath ?? this.mediaPath,
      reporterName: reporterName ?? this.reporterName,
      dateReported: dateReported ?? this.dateReported,
      status: status ?? this.status,
    );
  }
}
