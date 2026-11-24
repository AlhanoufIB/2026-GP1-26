import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Field title used above inputs. Required fields get a red "*".
class FieldLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const FieldLabel(this.text, {super.key, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            ),
        ],
      ),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.brownDark,
      ),
    );
  }
}
