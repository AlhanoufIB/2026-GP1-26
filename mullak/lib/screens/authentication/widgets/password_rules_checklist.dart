import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../utils/validators.dart';

/// Live checklist under the sign-up password field.
/// Each rule turns green the moment it is satisfied.
class PasswordRulesChecklist extends StatelessWidget {
  final TextEditingController controller;

  const PasswordRulesChecklist({super.key, required this.controller});

  static const _ok = Color(0xFF2F6B45);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final p = value.text;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final rule in passwordRules)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      rule.passes(p) && p.isNotEmpty
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 15,
                      color: rule.passes(p) && p.isNotEmpty
                          ? _ok
                          : AppColors.hint,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        rule.label,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: rule.passes(p) && p.isNotEmpty
                              ? _ok
                              : AppColors.hint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
