
import '../data/sample_properties.dart';
import '../dataconnect_generated/generated.dart';
import '../models/property.dart';

/// The ONLY place pages get property data from.
/// Pages call these methods and never talk to the database directly.
abstract class PropertyRepository {
  /// The one shared repository used by the whole app: the real database.
  static PropertyRepository instance = DataConnectPropertyRepository();

  /// All listings business owners can see (status = available).
  Future<List<Property>> getAvailableProperties();

  /// One listing by its id, or null if it does not exist.
  Future<Property?> getPropertyById(String propertyId);

  /// Several listings at once, in the same order as [ids].
  /// Ids that do not exist are skipped. Used by Saved and Compare.
  Future<List<Property>> getPropertiesByIds(List<String> ids);
}

/// Real database version (Firebase Data Connect).
class DataConnectPropertyRepository implements PropertyRepository {
  final MullakConnector _db = MullakConnector.instance;

  @override
  Future<List<Property>> getAvailableProperties() async {
    final result = await _db
        .listDiscoveryProperties()
        .execute();
    return result.data.properties
        .map((p) => _fromJson(p.toJson()))
        .toList();
  }

  @override
  Future<Property?> getPropertyById(String propertyId) async {
    final list = await getPropertiesByIds([propertyId]);
    return list.isEmpty ? null : list.first;
  }

  @override
  Future<List<Property>> getPropertiesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final result = await _db
        .listPropertiesByIds(ids: ids)
        .execute();
    final byId = {
      for (final p in result.data.properties) p.id: _fromJson(p.toJson()),
    };
    // keep the order of [ids] (e.g. newest saved first), skip missing ones
    return [
      for (final id in ids)
        if (byId[id] != null) byId[id]!,
    ];
  }

  /// One database row (as JSON) -> our Property model.
  Property _fromJson(Map<String, dynamic> json) {
    double toDouble(Object? v) => (v as num).toDouble();

    final images = (json['images'] as List<dynamic>? ?? const [])
        .map((e) => (e as Map<String, dynamic>)['imageUrl'] as String)
        .toList();
    final owner = json['owner'] as Map<String, dynamic>?;

    return Property(
      propertyId: json['id'] as String,
      ownerId: owner?['id'] as String? ?? '',
      title: json['title'] as String,
      district: json['district'] as String,
      city: json['city'] as String,
      propertyType: json['propertyType'] as String,
      areaSqm: toDouble(json['areaSqm']),
      rentPrice: toDouble(json['rentPrice']),
      status: json['status'] as String? ?? PropertyStatus.available,
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),
      estimatedPrice: json['estimatedPrice'] == null
          ? null
          : toDouble(json['estimatedPrice']),
      address: json['address'] as String?,
      description: json['description'] as String?,
      imageUrls: images,
      hasParking: json['hasParking'] as bool?,
    );
  }
}

/// Sample-data version. Kept ONLY for the unit tests in test/,
/// so they can run without a database connection.
class LocalPropertyRepository implements PropertyRepository {
  static const _delay = Duration(milliseconds: 300);

  @override
  Future<List<Property>> getAvailableProperties() async {
    await Future.delayed(_delay);
    return sampleProperties.where((p) => p.isAvailable).toList();
  }

  @override
  Future<Property?> getPropertyById(String propertyId) async {
    await Future.delayed(_delay);
    for (final p in sampleProperties) {
      if (p.propertyId == propertyId) return p;
    }
    return null;
  }

  @override
  Future<List<Property>> getPropertiesByIds(List<String> ids) async {
    await Future.delayed(_delay);
    return [
      for (final id in ids)
        for (final p in sampleProperties)
          if (p.propertyId == id) p,
    ];
  }
}
