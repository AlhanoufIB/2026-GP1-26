/// Data model for one commercial property listing.
///
/// The fields follow the PROPERTY entity in our data dictionary
/// (report section 4.4.2). [address] and [description] were added to the
/// PROPERTY table (both optional). [hasParking] is still NOT in the
/// dictionary ("PENDING TEAM DECISION").
class Property {
  // ---------- fields from the data dictionary ----------
  final String propertyId; // PK
  final String ownerId; // FK -> Property_Owner.user_ID
  final String title; // e.g. "محل زاوية، الملقا"
  final String district; // e.g. "الملقا"
  final String city; // e.g. "الرياض"
  final String propertyType; // one of PropertyType values below
  final double areaSqm; // must be > 0
  final double rentPrice; // SAR per year, must be >= 0
  final String status; // one of PropertyStatus values below
  final double latitude;
  final double longitude;
  final double? estimatedPrice; // filled later by the rent prediction model
  final String? address; // street / building (optional)
  final String? description; // shown in "وصف العقار" (optional)

  /// Image paths, already sorted by IMAGE.display_order.
  /// Today they are local asset paths; after Firebase they will be URLs.
  final List<String> imageUrls;

  // ---------- PENDING TEAM DECISION (not in the dictionary yet) ----------
  final bool? hasParking; // shown in "المواقف"

  const Property({
    required this.propertyId,
    required this.ownerId,
    required this.title,
    required this.district,
    required this.city,
    required this.propertyType,
    required this.areaSqm,
    required this.rentPrice,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.estimatedPrice,
    this.address,
    this.description,
    this.imageUrls = const [],
    this.hasParking,
  });

  /// True when the listing can be shown to business owners.
  bool get isAvailable => status == PropertyStatus.available;

  /// First image, used on cards. Null if the owner uploaded none.
  String? get coverImage => imageUrls.isEmpty ? null : imageUrls.first;

  /// Arabic label of the type, e.g. "shop" -> "محل".
  String get typeLabel => PropertyType.labelOf(propertyType);
}

/// The fixed list of property types from the data dictionary.
/// We store the English value in the database and show the Arabic label.
class PropertyType {
  static const shop = 'shop';
  static const office = 'office';
  static const kiosk = 'kiosk';
  static const warehouse = 'warehouse';

  static const all = [shop, office, kiosk, warehouse];

  static String labelOf(String type) {
    switch (type) {
      case shop:
        return 'محل';
      case office:
        return 'مكتب';
      case kiosk:
        return 'كشك';
      case warehouse:
        return 'مستودع';
      default:
        return type; // unknown value: show it as is instead of crashing
    }
  }
}

/// The fixed list of listing states from the data dictionary.
class PropertyStatus {
  static const available = 'available';
  static const rented = 'rented';
  static const hidden = 'hidden';
}
