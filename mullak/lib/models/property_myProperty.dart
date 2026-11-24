import '../dataconnect_generated/generated.dart';

/// المدينة ثابتة حالياً (التطبيق للرياض)
const String kDefaultCity = 'الرياض';

class PropertyImage {
  final String imageUrl;
  final int displayOrder; // 1 = الصورة الرئيسية
  const PropertyImage({required this.imageUrl, required this.displayOrder});
}

/// بيانات الكرت في عقاراتي (من ListMyProperties)
class PropertySummary {
  final String id;
  final String title;
  final String status;
  final double rentPrice;
  final double areaSqm;
  final String? coverImageUrl;

  const PropertySummary({
    required this.id,
    required this.title,
    required this.status,
    required this.rentPrice,
    required this.areaSqm,
    this.coverImageUrl,
  });

  factory PropertySummary.fromList(ListMyPropertiesProperties p) =>
      PropertySummary(
        id: p.id,
        title: p.title,
        status: p.status,
        rentPrice: p.rentPrice,
        areaSqm: p.areaSqm,
        coverImageUrl:
            p.myCoverImage.isEmpty ? null : p.myCoverImage.first.imageUrl,
      );

  String get shortId => listingNumber(id);
}

/// تفاصيل العقار (من GetProperty) وللإضافة والتعديل
class Property {
  final String id; // فاضي عند الإضافة
  final String title; // يكتبه المستخدم
  final String propertyType;
  final String? activityType; // اختياري
  final double areaSqm;
  final String district;
  final String city;
  final double rentPrice;
  final String status;
  final double latitude;
  final double longitude;
  final double? estimatedPrice;
  final String address;
  final String description;
  final bool hasParking;
  final List<PropertyImage> images;

  const Property({
    this.id = '',
    required this.title,
    required this.propertyType,
    this.activityType,
    required this.areaSqm,
    required this.district,
    this.city = kDefaultCity,
    required this.rentPrice,
    this.status = 'available',
    required this.latitude,
    required this.longitude,
    this.estimatedPrice,
    this.address = '',
    this.description = '',
    this.hasParking = false,
    this.images = const [],
  });

  String get shortId => listingNumber(id);

  factory Property.fromGet(GetPropertyProperty p) {
    final images = p.images
        .map((i) =>
            PropertyImage(imageUrl: i.imageUrl, displayOrder: i.displayOrder))
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return Property(
      id: p.id,
      title: p.title,
      propertyType: p.propertyType,
      activityType: p.activityType, // يحتاج توليد الـ SDK بعد تعديل الـ schema
      areaSqm: p.areaSqm,
      district: p.district,
      city: p.city,
      rentPrice: p.rentPrice,
      status: p.status,
      latitude: p.latitude,
      longitude: p.longitude,
      estimatedPrice: p.estimatedPrice,
      address: p.address ?? '',
      description: p.description ?? '',
      hasParking: p.hasParking ?? false,
      images: images,
    );
  }
}

String formatNumber(int n) => n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );

/// رقم عقار من 5 خانات (أرقام فقط) مشتق من المعرّف
String listingNumber(String id) {
  final hex = id.replaceAll('-', '');
  if (hex.length < 8) return '00000';
  final n = int.parse(hex.substring(0, 8), radix: 16) % 90000 + 10000;
  return n.toString();
}