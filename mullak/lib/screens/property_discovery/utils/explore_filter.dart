import '../../../models/property.dart';

/// The Explore filters, as plain data:
/// property type + budget range + space range. null = no limit.
///
/// Kept separate from the screen so the logic can be unit-tested
/// (see test/explore_filter_test.dart) without building any UI.
class ExploreFilter {
  final String? type;
  final double? minBudget;
  final double? maxBudget;
  final double? minSpace;
  final double? maxSpace;

  const ExploreFilter({
    this.type,
    this.minBudget,
    this.maxBudget,
    this.minSpace,
    this.maxSpace,
  });

  /// How many filters are on: type, budget, space (shown as "تصفية (2)").
  int get activeCount =>
      (type != null ? 1 : 0) +
      (minBudget != null || maxBudget != null ? 1 : 0) +
      (minSpace != null || maxSpace != null ? 1 : 0);

  bool get isAll => activeCount == 0;

  /// Keep only the properties that match every active filter.
  List<Property> apply(List<Property> properties) {
    return properties.where((p) {
      final typeOk = type == null || p.propertyType == type;
      final budgetOk = (minBudget == null || p.rentPrice >= minBudget!) &&
          (maxBudget == null || p.rentPrice <= maxBudget!);
      final spaceOk = (minSpace == null || p.areaSqm >= minSpace!) &&
          (maxSpace == null || p.areaSqm <= maxSpace!);
      return typeOk && budgetOk && spaceOk;
    }).toList();
  }
}