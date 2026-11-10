import 'package:flutter_test/flutter_test.dart';
import 'package:mullak/models/business_requirement.dart';
import 'package:mullak/services/recommendation_service.dart';

// Run with:  flutter test test/recommendation_service_test.dart
void main() {
  final service = RuleBasedRecommendationService();

  const cafeInMalqa = BusinessRequirement(
    requirementId: 'req_test',
    businessOwnerId: 'business_owner_1',
    businessType: 'مقهى',
    budget: 80000,
    requiredSpace: 60,
    preferredLocation: 'الملقا',
  );

  test('returns at most 3, ranked best first', () async {
    final results = await service.getRecommendations(cafeInMalqa);
    expect(results.length, lessThanOrEqualTo(3));
    for (var i = 0; i < results.length; i++) {
      expect(results[i].rank, i + 1);
      if (i > 0) {
        expect(results[i - 1].overallScore,
            greaterThanOrEqualTo(results[i].overallScore));
      }
    }
  });

  test('the Malqa shop is first: in budget, big enough, preferred district',
      () async {
    final results = await service.getRecommendations(cafeInMalqa);
    final best = results.first;
    expect(best.property.district, 'الملقا');
    expect(best.overallScore, 100);
    expect(best.tags, contains('ضمن الميزانية'));
    expect(best.explanation, contains('في موقعك المفضّل'));
  });

  test('scores always stay between 0 and 100', () async {
    const tinyBudget = BusinessRequirement(
      requirementId: 'req_low',
      businessOwnerId: 'business_owner_1',
      businessType: 'مقهى',
      budget: 1000,
      requiredSpace: 500,
    );
    final results = await service.getRecommendations(tinyBudget);
    for (final r in results) {
      expect(r.overallScore, inInclusiveRange(0, 100));
    }
  });
}
