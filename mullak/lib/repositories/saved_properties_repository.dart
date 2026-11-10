import 'package:flutter/foundation.dart';

/// The business owner's saved properties (the "saves" relationship in our ER).
/// Screens listen to it, so they update the moment something is saved.
/// TEMPORARY: kept in memory. Sprint 5 -> SAVED_PROPERTY table in Firebase.
class SavedPropertiesRepository extends ChangeNotifier {
  static final SavedPropertiesRepository instance =
      SavedPropertiesRepository._();
  SavedPropertiesRepository._(); // private constructor: only one instance

  final List<String> _savedIds = [];

  /// Newest first. Read-only copy, so screens can't change it by mistake.
  List<String> get savedIds => List.unmodifiable(_savedIds);

  bool isSaved(String propertyId) => _savedIds.contains(propertyId);

  /// Save if not saved, unsave if already saved (backlog acceptance criteria).
  void toggle(String propertyId) {
    if (isSaved(propertyId)) {
      _savedIds.remove(propertyId);
    } else {
      _savedIds.insert(0, propertyId);
    }
    notifyListeners(); // tell every listening screen to redraw
  }
}