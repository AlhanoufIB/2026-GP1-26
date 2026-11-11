/// Sends the user's problem reports and ratings.
///
/// Right now [FeedbackService.instance] is a mock that just waits a moment.
/// When the database is ready we write a real class that implements this
/// same interface and change the single line below.
abstract class FeedbackService {
  static FeedbackService instance = MockFeedbackService();

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