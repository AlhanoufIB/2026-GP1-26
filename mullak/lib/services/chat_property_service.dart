import '../dataconnect_generated/generated.dart';
import '../models/property.dart';

class ChatPropertyInfo {
  final Property property;
  final String ownerName;

  const ChatPropertyInfo({
    required this.property,
    required this.ownerName,
  });
}

class ChatPropertyService {
  ChatPropertyService._();

  static final ChatPropertyService instance =
      ChatPropertyService._();

  final MullakConnector _connector =
      MullakConnector.instance;

  Future<ChatPropertyInfo?> getProperty(
    String propertyId,
  ) async {
    final id = propertyId.trim();

    if (id.isEmpty) {
      return null;
    }

    // Get the property from Firebase Data Connect.
    final result = await _connector
        .getProperty(id: id)
        .execute();

    final data = result.data.property;

    if (data == null) {
      return null;
    }

    // Preserve the order of property images.
    final images = data.images.toList()
      ..sort(
        (a, b) =>
            a.displayOrder.compareTo(b.displayOrder),
      );

    // Convert Data Connect data to the app model.
    final property = Property(
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
      hasParking: data.hasParking,
      imageUrls: images
          .map((image) => image.imageUrl)
          .toList(),
    );

    return ChatPropertyInfo(
      property: property,
      ownerName: data.owner.fullName,
    );
  }
}