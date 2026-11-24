import 'package:flutter/foundation.dart';

import '../dataconnect_generated/generated.dart';

/// The business owner's saved properties ("saves": Business Owner 0..* --
/// 0..* Property), stored in the database as users.savedPropertyIds
/// (a list column on the signed-in user's own row).
/// Screens listen to it, so they update the moment something is saved.
class SavedPropertiesRepository extends ChangeNotifier {
  static final SavedPropertiesRepository instance =
      SavedPropertiesRepository._();
  SavedPropertiesRepository._();

  final MullakConnector _db = MullakConnector.instance;
  final List<String> _savedIds = [];

  /// Newest first. Read-only copy, so screens can't change it by mistake.
  List<String> get savedIds => List.unmodifiable(_savedIds);

  bool isSaved(String propertyId) => _savedIds.contains(propertyId);

  /// Load the signed-in user's saved list from the database.
  Future<void> refresh() async {
    try {
      final result = await _db
          .getMySavedPropertyIds()
          .execute();
      final ids = result.data.user?.savedPropertyIds ?? const <String>[];
      _savedIds
        ..clear()
        ..addAll(ids.reversed); // database adds at the end -> newest first
      notifyListeners();
    } catch (e) {
      debugPrint('Could not load saved properties: $e');
    }
  }

  /// Save if not saved, unsave if already saved.
  /// The screen updates right away; if the database fails, it's undone.
  Future<void> toggle(String propertyId) async {
    final wasSaved = isSaved(propertyId);
    if (wasSaved) {
      _savedIds.remove(propertyId);
    } else {
      _savedIds.insert(0, propertyId);
    }
    notifyListeners();

    try {
      if (wasSaved) {
        await _db.unsaveProperty(propertyId: propertyId).execute();
      } else {
        await _db.saveProperty(propertyId: propertyId).execute();
      }
    } catch (e) {
      debugPrint('Could not update saved properties: $e');
      if (wasSaved) {
        _savedIds.insert(0, propertyId);
      } else {
        _savedIds.remove(propertyId);
      }
      notifyListeners();
    }
  }
}
