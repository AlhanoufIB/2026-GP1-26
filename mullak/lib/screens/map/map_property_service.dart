import 'package:firebase_data_connect/firebase_data_connect.dart';

import '../../dataconnect_generated/generated.dart';
import '../../models/property.dart';

class MapPropertyService {
  final MullakConnector _connector = MullakConnector.instance;

  // Fetch available listings for map markers and filters.
  Future<List<ListAvailablePropertiesProperties>>
      getAvailableProperties() async {
    final result = await _connector
        .listAvailableProperties()
        .execute(fetchPolicy: QueryFetchPolicy.serverOnly);

    return result.data.properties;
  }

  // Fetch complete details only when the user requests them.
  Future<Property?> getPropertyById(String propertyId) async {
    final result = await _connector
        .getProperty(id: propertyId)
        .execute(fetchPolicy: QueryFetchPolicy.serverOnly);

    final data = result.data.property;

    if (data == null) {
      return null;
    }

    return Property(
      propertyId: data.id,
      ownerId: data.owner.id,
      title: data.title,
      district: data.district,
      city: data.city,
      propertyType: data.propertyType,
      areaSqm: data.areaSqm,
      rentPrice: data.rentPrice,
      status: data.status,
      latitude: data.latitude,
      longitude: data.longitude,
      estimatedPrice: data.estimatedPrice,
      address: data.address,
      description: data.description,
      imageUrls: data.images
          .map((image) => image.imageUrl)
          .toList(),
      hasParking: data.hasParking,
    );
  }
}