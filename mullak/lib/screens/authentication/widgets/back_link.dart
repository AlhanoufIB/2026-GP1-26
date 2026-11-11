import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// "→ رجوع" at the top of a page (the word on the right, the arrow on its left).
class BackLink extends StatelessWidget {
  const BackLink({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(8),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'رجوع',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.brownDark,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.arrow_forward, size: 15, color: AppColors.brownDark),
          ],
        ),
      ),
    );
  }
}