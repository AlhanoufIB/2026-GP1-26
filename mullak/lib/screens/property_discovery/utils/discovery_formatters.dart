/// Small helpers that turn numbers into the text shown in the designs.

/// 78000 -> "78,000"
String formatNumber(double value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    // add a comma before every group of 3 digits (counting from the right)
    final remaining = digits.length - i;
    if (i > 0 && remaining % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// 78000 -> "78,000 ر.س / سنة"   (rent_price is per year)
String formatYearlyRent(double rent) => '${formatNumber(rent)} ر.س / سنة';

/// 85 -> "85 م²"   and   85.5 -> "85.5 م²"
String formatArea(double area) {
  final isWhole = area == area.roundToDouble();
  final number = isWhole ? area.toInt().toString() : area.toStringAsFixed(1);
  return '$number م²';
}
