import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CustomButtonType { filled, outlined, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = CustomButtonType.filled,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    Widget button;
    if (type == CustomButtonType.outlined) {
      button = OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: shape,
        ),
        child: label,
      );
    } else {
      button = ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: type == CustomButtonType.danger
              ? AppColors.danger
              : AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: shape,
        ),
        child: label,
      );
    }

    return SizedBox(width: double.infinity, height: 56, child: button);
  }
}