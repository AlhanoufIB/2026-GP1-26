import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import '../dataconnect_generated/generated.dart';
import '../models/property_myProperty.dart';
import 'image_upload_service.dart';

class PropertyService {
  PropertyService._();
  static final instance = PropertyService._();

  final _connector = MullakConnector.instance;
  final _images = ImageUploadService.instance;

   Future<List<PropertySummary>> listMyProperties() async {
    final ref = _connector.listMyProperties().ref();
    final r = await ref.execute(fetchPolicy: QueryFetchPolicy.serverOnly);
    return r.data.properties
        .map(PropertySummary.fromList)
        .where((p) => p.status != 'hidden')
        .toList();
  }

  Future<Property?> getProperty(String id) async {
        final r = await _connector
        .getProperty(id: id)
        .ref()
        .execute(fetchPolicy: QueryFetchPolicy.serverOnly);
    final p = r.data.property;
    return p == null ? null : Property.fromGet(p);
  }

  String? _nullIfEmpty(String s) => s.isEmpty ? null : s;

  List<String> _order(List<String> paths, int mainIndex) {
    final ordered = [...paths];
    if (mainIndex > 0 && mainIndex < ordered.length) {
      ordered.insert(0, ordered.removeAt(mainIndex));
    }
    return ordered;
  }

  /// يرفع الملفات الجديدة ويرجّع روابط نهائية (الموجودة تبقى كما هي)
  Future<List<String>> _uploadAll(List<String> ordered) async {
    final urls = <String>[];
    for (final path in ordered) {
      urls.add(path.startsWith('http') ? path : await _images.upload(path));
    }
    return urls;
  }

  Future<void> _addImageRecords(String propertyId, List<String> urls) async {
    for (var i = 0; i < urls.length; i++) {
      await _connector
          .addPropertyImage(
            propertyId: propertyId,
            imageUrl: urls[i],
            displayOrder: i + 1,
          )
          .execute();
    }
  }

  /// يضيف عقار. الصور تُرفع أول، ولو فشل شي بعد الإنشاء يُخفى العقار.
  Future<String> createProperty(
    Property p, {
    required List<String> imagePaths,
    required int mainIndex,
  }) async {
    final urls = await _uploadAll(_order(imagePaths, mainIndex));

    String? id;
    try {
      final res = await _connector
          .createProperty(
            title: p.title,
            district: p.district,
            city: p.city,
            propertyType: p.propertyType,
            areaSqm: p.areaSqm,
            rentPrice: p.rentPrice,
            latitude: p.latitude,
            longitude: p.longitude,
          )
          .estimatedPrice(p.estimatedPrice)
          .address(_nullIfEmpty(p.address))
          .description(_nullIfEmpty(p.description))
          .hasParking(p.hasParking)
          .execute();
      id = res.data.property_insert.id;
      await _addImageRecords(id, urls);
      return id;
    } catch (e) {
      if (id != null) {
        try {
          await _connector
              .deleteMyPropertyImages(propertyId: id)
              .execute();
          await _connector.deleteMyProperty(id: id).execute();
        } catch (_) {
          try {
            await _connector
                .updateMyPropertyStatus(id: id, status: 'hidden')
                .execute();
          } catch (_) {}
        }
      }
      rethrow;
    }
  }

  Future<void> updateProperty(
    Property p, {
    required List<String> imagePaths,
    required int mainIndex,
  }) async {
    final urls = await _uploadAll(_order(imagePaths, mainIndex));

    await _connector
        .updateMyProperty(
          id: p.id,
          title: p.title,
          district: p.district,
          propertyType: p.propertyType,
          areaSqm: p.areaSqm,
          rentPrice: p.rentPrice,
          latitude: p.latitude,
          longitude: p.longitude,
        )
        .estimatedPrice(p.estimatedPrice)
        .address(_nullIfEmpty(p.address))
        .description(_nullIfEmpty(p.description))
        .hasParking(p.hasParking)
        .execute();

    await _connector.deleteMyPropertyImages(propertyId: p.id).execute();
    await _addImageRecords(p.id, urls);
  }

    /// حذف نهائي. النجاح يُحكم عليه بحالة الداتابيس.
  Future<void> deleteProperty(String id) async {
    try {
      await _connector.deleteMyPropertyImages(propertyId: id).execute();
    } catch (e) {
      debugPrint('DELETE IMAGES CALL: $e');
    }
    try {
      await _connector.deleteMyProperty(id: id).execute();
    } catch (e) {
      debugPrint('DELETE PROPERTY CALL: $e');
    }

    // نتحقق: لو القراءة رجّعت null أو رمت خطأ، يعني العقار انحذف
    Property? still;
    try {
      still = await getProperty(id);
    } catch (_) {
      still = null;
    }
    if (still != null) {
      throw Exception('العقار ما انحذف من الداتابيس');
    }
  }
}