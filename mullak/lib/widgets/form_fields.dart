import 'package:flutter/material.dart';
import 'dart:ui' show PathMetric;
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// ───────── مكونات الفورم الموحّدة لكل التطبيق ─────────
/// أي فورم جديد يستخدم هذه المكونات ليطلع بنفس الشكل:
///  - FormFieldLabel(required: true)  → عنوان الحقل + نجمة بلون الخطأ
///  - RequiredNote()                  → "* حقول مطلوبة" تحت عنوان الصفحة
///  - AppTextField / AppDropdownField → حقول بنفس الحدود والألوان
///  - FieldErrorText                  → رسالة خطأ لعناصر مخصصة (خريطة، خيارات…)

const double kFieldRadius = 14;

InputDecoration appInputDecoration(String hint, {bool hasError = false}) {
  OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(kFieldRadius),
        borderSide: BorderSide(color: c, width: 1.5),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: border(AppColors.border),
    enabledBorder: border(AppColors.border),
    focusedBorder: border(AppColors.primary),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger),
    errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
  );
}

/// عنوان حقل، ولو required تظهر النجمة بعد النص (يسار النص في RTL) كما في التصميم.
class FormFieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const FormFieldLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          if (required)
            const Text(' *',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.danger)),
        ],
      ),
    );
  }
}

/// السطر الصغير تحت عنوان الصفحة.
class RequiredNote extends StatelessWidget {
  const RequiredNote({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Text('* حقول مطلوبة',
            style: TextStyle(fontSize: 13, color: AppColors.danger)),
      );
}

class FieldErrorText extends StatelessWidget {
  final String text;
  const FieldErrorText(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, right: 6),
        child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
      );
}

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
        decoration: appInputDecoration(hint),
      );
}

class AppDropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;

  const AppDropdownField({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
        decoration: appInputDecoration(hint),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
        validator: validator,
      );
}


/// صندوق بحدود متقطعة (للخريطة وإضافة الصور) — نفس شكل التصميم.
class DashedBox extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double height;
  final bool hasError;
  const DashedBox({
    super.key,
    required this.child,
    this.onTap,
    this.height = 76,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kFieldRadius),
        child: CustomPaint(
          painter: _DashedPainter(hasError ? AppColors.danger : AppColors.border),
          child: Container(
            width: double.infinity,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.beige,
              borderRadius: BorderRadius.circular(kFieldRadius),
            ),
            child: child,
          ),
        ),
      );
}

class _DashedPainter extends CustomPainter {
  final Color color;
  _DashedPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(kFieldRadius)));
    for (final PathMetric m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter old) => old.color != color;
}