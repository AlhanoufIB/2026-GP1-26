import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// A label above a big multi-line text box (details / experience).
class TextAreaField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  /// How many lines tall the box is.
  final int lines;

  const TextAreaField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.lines = 4,
  });

  OutlineInputBorder _border(Color color, {double width = 1.2}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.brownDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          minLines: lines,
          maxLines: lines,
          maxLength: 600,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          cursorColor: AppColors.brown,
          style: const TextStyle(fontSize: 13.5, color: AppColors.brownDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.hint),
            counterText: '', // hides the "0/600" counter
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.brown, width: 1.6),
          ),
        ),
      ],
    );
  }
}