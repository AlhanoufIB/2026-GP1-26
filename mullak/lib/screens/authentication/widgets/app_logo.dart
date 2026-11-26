import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/back_link.dart';

/// Path of the logo image. To use a logo of your own, change this one line.
const String _logoAsset = 'assets/images/logo.png';

/// Shows the Mullak logo. [size] is the HEIGHT; the width follows the image.
///
/// [blendColor]: if the PNG has a white background, pass the color of the
/// surface behind it so the white melts into it. Not needed for a
/// transparent PNG.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showLabel; // placeholder only
  final Color? blendColor;

  const AppLogo({
    super.key,
    this.size = 72,
    this.showLabel = false,
    this.blendColor,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _logoAsset,
      height: size,
      fit: BoxFit.contain,
      color: blendColor,
      colorBlendMode: blendColor == null ? null : BlendMode.multiply,
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

/// The top row of the login and sign-up screens (as in Figma):
///   "رجوع →" on the right, the logo on the left.
class AuthTopBar extends StatelessWidget {
  const AuthTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // In a right-to-left app the FIRST child sits on the right.
        // shared "رجوع" link (same as the other pages, arrow on the right)
        const BackLink(text: 'رجوع'),
        const Spacer(),
        const AppLogo(size: 60, blendColor: AppColors.background),
      ],
    );
  }
}