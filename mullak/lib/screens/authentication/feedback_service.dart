import '../../dataconnect_generated/generated.dart';

/// Sends the user's problem reports and ratings.
///
/// [FeedbackService.instance] is now [FirebaseFeedbackService], which saves
/// to the REPORT and REVIEW tables in SQL Connect. To go back to the offline
/// mock, change the line below to `MockFeedbackService()`.
abstract class FeedbackService {
  static FeedbackService instance = FirebaseFeedbackService();

  Future<void> submitReport({
    required String type,
    required String details,
  });

  Future<void> submitRating({
    required int stars, // 1 to 5
    required String comment,
  });
}

class MockFeedbackService implements FeedbackService {
  @override
  Future<void> submitReport({
    required String type,
    required String details,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
  }

  @override
  Future<void> submitRating({
    required int stars,
    required String comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
  }
}

/// Real backend: saves to the SQL Connect database.
/// The logged-in user's id is added on the server (auth.uid), so a user
/// can only send reports / reviews as themselves.
class FirebaseFeedbackService implements FeedbackService {
  final MullakConnector _db = MullakConnector.instance;

  @override
  Future<void> submitReport({
    required String type,
    required String details,
  }) async {
    await _db
        .createReport(
          // Report_type: the option the user picked (max 50 characters)
          reportType: type,
          // description is required in the data dictionary; when the user
          // left the details empty we store the type itself.
          description: details.isEmpty ? type : details,
        )
        .execute();
  }

  @override
  Future<void> submitRating({
    required int stars,
    required String comment,
  }) async {
    if (stars < 1 || stars > 5) {
      throw ArgumentError('rating must be 1-5');
    }
    await _db
        .createReview(rating: stars)
        .comment(comment.isEmpty ? null : comment) // comment is optional
        .execute();
  }
}
