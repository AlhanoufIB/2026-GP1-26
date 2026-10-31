import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// "مستخدم جديد؟ إنشاء حساب" style link line under the button.
class BottomSwitchLink extends StatelessWidget {
  final String question;
  final String actionText;
  final VoidCallback onTap;

  const BottomSwitchLink({
    super.key,
    required this.question,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 12, color: AppColors.hint),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.brownDark,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
