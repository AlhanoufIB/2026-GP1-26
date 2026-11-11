class property_myProperty {
  final int id;
  final String type;
  final int area;
  final String location;
  final int annualRent;
  final String description;
  final List<String> imagePaths;
  final int mainImageIndex;
  final double? lat;
  final double? lng;

  const property_myProperty({
    required this.id,
    required this.type,
    required this.area,
    required this.location,
    required this.annualRent,
    this.description = '',
    this.imagePaths = const [],
    this.mainImageIndex = 0,
    this.lat,
    this.lng,
  });

  String get title => '$type، $location';

  /// الصورة اللي تظهر برا (في عقاراتي والاستكشاف...)
  String? get mainImage =>
      imagePaths.isEmpty ? null : imagePaths[mainImageIndex];
}

String formatNumber(int n) => n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );