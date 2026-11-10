import '../../../models/property.dart';

/// The filter chips on the Explore page, as plain data.
///
/// Kept separate from the screen so the logic can be unit-tested
/// (see test/explore_filter_test.dart) without building any UI.
class ExploreFilter {
  /// Area limit for the "أقل من 80 م²" chip.
  static const double smallAreaLimit = 80;

  /// Selected property type, or null when no type is selected.
  final String? type;

  /// True when "أقل من 80 م²" is on.
  final bool onlySmall;

  const ExploreFilter({this.type, this.onlySmall = false});

  /// "الكل" is highlighted when nothing else is selected.
  bool get isAll => type == null && !onlySmall;

  /// Tapping a type chip: select it, or clear it if it was already selected.
  ExploreFilter toggleType(String newType) => ExploreFilter(
        type: type == newType ? null : newType,
        onlySmall: onlySmall,
      );

  /// Tapping "أقل من 80 م²": switch it on or off, keep the type.
  ExploreFilter toggleSmall() => ExploreFilter(type: type, onlySmall: !onlySmall);

  /// Keep only the properties that match every active filter.
  List<Property> apply(List<Property> properties) {
    return properties.where((p) {
      final typeOk = type == null || p.propertyType == type;
      final areaOk = !onlySmall || p.areaSqm < smallAreaLimit;
      return typeOk && areaOk;
    }).toList();
  }
}
