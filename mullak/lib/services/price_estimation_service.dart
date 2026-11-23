class PriceEstimate {
  final int price;
  final int min;
  final int max;
  const PriceEstimate(this.price, this.min, this.max);
}

class PriceEstimationService {
  PriceEstimationService._();

  // TODO: استبدلها باستدعاء نموذج الذكاء الاصطناعي / الـ API
  static PriceEstimate estimate({
    required String type,
    required int area,
    required String district,
  }) {
    final price = ((area * 894) / 500).round() * 500;
    final min = ((price * 0.92) / 1000).round() * 1000;
    final max = ((price * 1.09) / 1000).round() * 1000;
    return PriceEstimate(price, min, max);
  }
}