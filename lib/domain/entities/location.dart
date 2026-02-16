class Location {
  final double latitude;
  final double longitude;
  final String? address;

  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  String get displayText =>
      address ?? '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}
