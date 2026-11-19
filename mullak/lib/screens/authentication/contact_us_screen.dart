import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';
import 'widgets/back_link.dart';

/// "تواصل معنا": the team's contact details.
/// Tapping a row copies it so the user can paste it in the phone or mail app.
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  // TODO: put the team's real contact details here.
  static const phone = '+966 5X XXX XXXX';
  static const email = 'mullak@example.com';

  void _copy(BuildContext context, String value, String msg) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppBottomNav(current: AppTab.account),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackLink(),
              const SizedBox(height: 8),
              const Text(
                'تواصل معنا',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brownDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'يسعدنا تواصلك معنا لأي استفسار أو اقتراح.',
                style: TextStyle(fontSize: 12.5, color: AppColors.hint),
              ),
              const SizedBox(height: 22),
              _ContactRow(
                icon: Icons.phone_outlined,
                label: 'رقم الجوال',
                value: phone,
                onTap: () => _copy(context, phone, 'تم نسخ رقم الجوال'),
              ),
              const SizedBox(height: 14),
              _ContactRow(
                icon: Icons.mail_outline,
                label: 'البريد الإلكتروني',
                value: email,
                onTap: () =>
                    _copy(context, email, 'تم نسخ البريد الإلكتروني'),
              ),
              const SizedBox(height: 18),
              const Text(
                'اضغط على الرقم أو البريد لنسخه.',
                style: TextStyle(fontSize: 11.5, color: AppColors.hint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White card: icon on the right, label + value, copy icon on the left.
class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.gradientStart,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: AppColors.brownDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.hint,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        value,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brownDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.copy_outlined,
                    size: 18, color: AppColors.hint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
