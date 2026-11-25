/// Shared form validators, input filters and phone helpers.
///
/// Every validator returns an Arabic error message, or null when the value
/// is valid. The forms use AutovalidateMode.onUserInteraction, so these run
/// on every keystroke and the error appears immediately.
library;

import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Digits
// ---------------------------------------------------------------------------

/// Converts Arabic-Indic (٠-٩) and Persian (۰-۹) digits to 0-9, so a user
/// typing on an Arabic keyboard is not rejected.
String toWesternDigits(String s) {
  final b = StringBuffer();
  for (final r in s.runes) {
    if (r >= 0x0660 && r <= 0x0669) {
      b.writeCharCode(0x30 + r - 0x0660);
    } else if (r >= 0x06F0 && r <= 0x06F9) {
      b.writeCharCode(0x30 + r - 0x06F0);
    } else {
      b.writeCharCode(r);
    }
  }
  return b.toString();
}

/// Typing filter for the phone field:
/// - converts Arabic digits to 0-9
/// - keeps only digits, spaces and a "+" at the very start
/// - stops at 16 characters ("+966 5X XXX XXXX")
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var t = toWesternDigits(newValue.text);
    final b = StringBuffer();
    for (var i = 0; i < t.length; i++) {
      final c = t[i];
      final isDigit = c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;
      if (isDigit || c == ' ' || (c == '+' && b.isEmpty)) b.write(c);
    }
    t = b.toString();
    if (t.length > 16) t = t.substring(0, 16);
    if (t == newValue.text) return newValue;
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}

// ---------------------------------------------------------------------------
// Phone
// ---------------------------------------------------------------------------

const _lrm = '\u200E'; // keeps "+966" readable inside Arabic text
const _phonePrefixError = 'رقم الجوال يجب أن يبدأ بـ 05 أو $_lrm+966';

String _digitsLeft(int n) {
  if (n == 1) return 'بقي رقم واحد';
  if (n == 2) return 'بقي رقمان';
  return 'بقي $n أرقام';
}

/// Accepts only 05XXXXXXXX (10 digits) or +9665XXXXXXXX. Spaces are ignored.
String? validatePhone(String? v) {
  final value = toWesternDigits(v ?? '').replaceAll(' ', '');
  if (value.isEmpty) return 'الرجاء إدخال رقم الجوال';
  if (!RegExp(r'^\+?\d+$').hasMatch(value)) {
    return 'رقم الجوال يجب أن يحتوي على أرقام فقط';
  }

  if (value.startsWith('+')) {
    // International form: +966 5XXXXXXXX
    if (value.length <= 4) {
      return '+966'.startsWith(value)
          ? 'رقم الجوال غير مكتمل'
          : _phonePrefixError;
    }
    if (!value.startsWith('+966')) return _phonePrefixError;
    if (value[4] != '5') return 'رقم الجوال بعد $_lrm+966 يجب أن يبدأ بـ 5';
    final local = value.length - 4; // must be 9 digits
    if (local < 9) return 'رقم الجوال غير مكتمل، ${_digitsLeft(9 - local)}';
    if (local > 9) return 'رقم الجوال أطول من اللازم';
    return null;
  }

  // Local form: 05XXXXXXXX
  if (value[0] != '0') return _phonePrefixError;
  if (value.length >= 2 && value[1] != '5') return _phonePrefixError;
  if (value.length < 10) {
    return 'رقم الجوال غير مكتمل، ${_digitsLeft(10 - value.length)}';
  }
  if (value.length > 10) return 'رقم الجوال يجب أن يكون 10 أرقام فقط';
  return null;
}

/// Turns 05XXXXXXXX or +9665XXXXXXXX into +9665XXXXXXXX
/// (the form stored in the database).
String normalizePhone(String input) {
  var p = toWesternDigits(input).replaceAll(' ', '');
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

// ---------------------------------------------------------------------------
// Full name
// ---------------------------------------------------------------------------

const int nameMaxLength = 50;

final _arabicLetter = RegExp(r'[\u0621-\u063A\u0641-\u064A]');
final _englishLetter = RegExp(r'[A-Za-z]');
final _anyDigit = RegExp(r'[0-9\u0660-\u0669\u06F0-\u06F9]');
// Arabic letters (+ harakat) or English letters, and spaces.
final _nameChars =
    RegExp(r'^[A-Za-z\u0621-\u063A\u0641-\u064A\u064B-\u0652\u0670 ]+$');

/// Collapses repeated spaces and trims ("  سارة   أحمد " -> "سارة أحمد").
String cleanName(String input) =>
    input.trim().replaceAll(RegExp(r'\s+'), ' ');

String? validateFullName(String? v) {
  final value = cleanName(v ?? '');
  if (value.isEmpty) return 'الرجاء إدخال الاسم الكامل';
  if (_anyDigit.hasMatch(value)) return 'الاسم لا يمكن أن يحتوي على أرقام';
  if (!_nameChars.hasMatch(value)) {
    return 'الاسم يجب أن يحتوي على أحرف فقط، بدون رموز';
  }
  if (_arabicLetter.hasMatch(value) && _englishLetter.hasMatch(value)) {
    return 'اكتب الاسم بالعربية أو بالإنجليزية، وليس بالاثنتين';
  }
  if (value.length > nameMaxLength) {
    return 'الاسم طويل جدًا ($nameMaxLength حرفًا كحد أقصى)';
  }
  final parts = value.split(' ');
  if (parts.length < 2) return 'اكتب الاسم الأول واسم العائلة';
  final letters = RegExp(r'[A-Za-z\u0621-\u063A\u0641-\u064A]');
  if (parts.any((p) => letters.allMatches(p).length < 2)) {
    return 'كل جزء من الاسم يجب أن يكون حرفين على الأقل';
  }
  return null;
}

// ---------------------------------------------------------------------------
// Password
// ---------------------------------------------------------------------------

const int passwordMinLength = 8;
const int passwordMaxLength = 64;

/// One password rule: the text shown in the checklist, the error message,
/// and the test.
class PasswordRule {
  final String label;
  final String error;
  final bool Function(String) passes;
  const PasswordRule(this.label, this.error, this.passes);
}

// Printable English characters only (letters, digits, symbols; no spaces).
final _englishOnly = RegExp(r'^[\x21-\x7E]*$');
final _special = RegExp(r'''[!@#$%^&*()_+\-=\[\]{};:'"\\|,.<>/?`~]''');

final List<PasswordRule> passwordRules = [
  PasswordRule(
    '$passwordMinLength خانات على الأقل',
    'كلمة المرور يجب أن تكون $passwordMinLength خانات على الأقل',
    (p) => p.length >= passwordMinLength,
  ),
  PasswordRule(
    'حرف إنجليزي كبير (A-Z)',
    'أضف حرفًا إنجليزيًا كبيرًا (A-Z)',
    (p) => RegExp(r'[A-Z]').hasMatch(p),
  ),
  PasswordRule(
    'حرف إنجليزي صغير (a-z)',
    'أضف حرفًا إنجليزيًا صغيرًا (a-z)',
    (p) => RegExp(r'[a-z]').hasMatch(p),
  ),
  PasswordRule(
    'رقم واحد على الأقل (0-9)',
    'أضف رقمًا واحدًا على الأقل (0-9)',
    (p) => RegExp(r'[0-9]').hasMatch(p),
  ),
  PasswordRule(
    'رمز خاص واحد على الأقل (مثل ! @ # \$ %)',
    'أضف رمزًا خاصًا واحدًا على الأقل (مثل ! @ # \$ %)',
    (p) => _special.hasMatch(p),
  ),
  PasswordRule(
    'بدون مسافات',
    'كلمة المرور لا يمكن أن تحتوي على مسافات',
    (p) => !p.contains(RegExp(r'\s')),
  ),
  PasswordRule(
    'أحرف وأرقام ورموز إنجليزية فقط',
    'استخدم أحرفًا وأرقامًا ورموزًا إنجليزية فقط',
    (p) => _englishOnly.hasMatch(p.replaceAll(RegExp(r'\s'), '')),
  ),
];

/// For CREATING a password (sign up). [phone] is optional: when given, the
/// password may not contain the phone number.
String? validateNewPassword(String? v, {String? phone}) {
  final p = v ?? '';
  if (p.isEmpty) return 'الرجاء إدخال كلمة المرور';
  for (final rule in passwordRules) {
    if (!rule.passes(p)) return rule.error;
  }
  if (p.length > passwordMaxLength) {
    return 'كلمة المرور طويلة جدًا ($passwordMaxLength خانة كحد أقصى)';
  }
  if (phone != null) {
    final digits = toWesternDigits(phone).replaceAll(RegExp(r'\D'), '');
    // the 9 digits after 0 / +966, e.g. 5XXXXXXXX
    if (digits.length >= 9) {
      final core = digits.substring(digits.length - 9);
      if (p.contains(core)) return 'كلمة المرور لا يمكن أن تحتوي على رقم الجوال';
    }
  }
  return null;
}

/// For LOGGING IN. Only checks that something was typed: older accounts were
/// created before the stronger rules, so they must still be able to log in.
String? validatePassword(String? v) {
  if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
  return null;
}

// ---------------------------------------------------------------------------
// Free text (report details, rating comment)
// ---------------------------------------------------------------------------

const int freeTextMaxLength = 600;

/// [required]: whether an empty value is an error.
/// [minLength]: minimum length when something is written.
String? validateFreeText(
  String? v, {
  required bool required,
  required String emptyMessage,
  int minLength = 10,
}) {
  final value = (v ?? '').trim();
  if (value.isEmpty) return required ? emptyMessage : null;
  if (value.length < minLength) {
    return 'اكتب $minLength أحرف على الأقل (${value.length}/$minLength)';
  }
  if (value.length > freeTextMaxLength) {
    return 'النص طويل جدًا ($freeTextMaxLength حرف كحد أقصى)';
  }
  if (!_arabicLetter.hasMatch(value) && !_englishLetter.hasMatch(value)) {
    return 'اكتب وصفًا واضحًا بالكلمات، وليس أرقامًا أو رموزًا فقط';
  }
  if (RegExp(r'(.)\1{5,}').hasMatch(value)) {
    return 'النص يحتوي على تكرار غير مفهوم لنفس الحرف';
  }
  if (RegExp(r'(https?://|www\.)', caseSensitive: false).hasMatch(value)) {
    return 'لا يمكن إضافة روابط في هذه الخانة';
  }
  if (RegExp(r'<[^>]*>').hasMatch(value)) {
    return 'النص يحتوي على رموز غير مسموحة';
  }
  return null;
}
