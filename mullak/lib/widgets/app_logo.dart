import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

/// Shows the Mullak logo from [kLogoAsset].
/// If the image file is not added yet, it shows a placeholder box instead,
/// so the app always runs. See lib/constants/app_assets.dart to add the logo.
class AppLogo extends StatelessWidget {
  final double size;

  /// Placeholder only: also write the word "مُلّاك" under the icon.
  final bool showLabel;

  const AppLogo({super.key, this.size = 72, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      kLogoAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          _LogoPlaceholder(size: size, showLabel: showLabel),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  final double size;
  final bool showLabel;

  const _LogoPlaceholder({required this.size, required this.showLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.apartment_rounded,
            size: size * (showLabel ? 0.4 : 0.5),
            color: AppColors.brownDark,
          ),
          if (showLabel && size >= 64)
            Text(
              'مُلّاك',
              style: TextStyle(
                fontSize: size * 0.17,
                fontWeight: FontWeight.w800,
                color: AppColors.brownDark,
              ),
            ),
        ],
      ),
    );
  }
}
