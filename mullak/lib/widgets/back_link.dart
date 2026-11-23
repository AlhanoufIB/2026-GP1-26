import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// رابط الرجوع: النص ثم السهم (→)، ملتصق باليمين،
/// بنفس الشكل سواء كان الجهاز عربي أو إنجليزي
class BackLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const BackLink({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // نثبّت الاتجاه LTR عشان الترتيب والمحاذاة ما ينقلبون
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: onTap ?? () => Navigator.pop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward,
                  size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}