/// Shared form validators + phone helpers.

String? validatePhone(String? v) {
  final value = (v ?? '').replaceAll(' ', '');
  if (value.isEmpty) return 'الرجاء إدخال رقم الجوال';
  // Accepts 05XXXXXXXX, 5XXXXXXXX, +9665XXXXXXXX, 009665XXXXXXXX
  final ok = RegExp(r'^(\+966|00966|0)?5\d{8}$').hasMatch(value);
  if (!ok) return 'رقم الجوال غير صحيح';
  return null;
}

String? validatePassword(String? v) {
  if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
  if (v.length < 8) return 'كلمة المرور يجب أن تكون ٨ خانات على الأقل';
  return null;
}

/// Turns any accepted format into the international form +9665XXXXXXXX.
/// This is the form we store in the database.
String normalizePhone(String input) {
  var p = input.replaceAll(' ', '');
  if (p.startsWith('+966')) return p;
  if (p.startsWith('00966')) return '+${p.substring(2)}';
  if (p.startsWith('0')) p = p.substring(1);
  return '+966$p';
}

/// +966555123456  ->  "+966 55 123 4567" (for showing to the user).
String formatPhone(String normalized) {
  final m = RegExp(r'^\+966(5\d)(\d{3})(\d{4})$').firstMatch(normalized);
  if (m == null) return normalized;
  return '+966 ${m.group(1)} ${m.group(2)} ${m.group(3)}';
}
