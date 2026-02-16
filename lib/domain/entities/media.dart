class Media {
  final String id;
  final String incidentId;
  final String fileUrl;
  final String fileType;
  final DateTime? createdAt;

  const Media({
    required this.id,
    required this.incidentId,
    required this.fileUrl,
    required this.fileType,
    this.createdAt,
  });
}
