import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Shows a property photo from a local asset ("assets/images/...")
/// or a web URL ("https://..."). Shows a placeholder if missing or broken.
class PropertyImage extends StatelessWidget {
  final String? path;
  final BoxFit fit;

  const PropertyImage({super.key, required this.path, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final source = path;
    if (source == null) return const _Placeholder();

    Widget onError(BuildContext context, Object error, StackTrace? stack) =>
        const _Placeholder();

    if (source.startsWith('http')) {
      return Image.network(source, fit: fit, errorBuilder: onError);
    }
    return Image.asset(source, fit: fit, errorBuilder: onError);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gradientStart,
      alignment: Alignment.center,
      child: const Icon(Icons.storefront_outlined, size: 36, color: AppColors.brown),
    );
  }
}