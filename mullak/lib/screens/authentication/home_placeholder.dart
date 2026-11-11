import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import 'welcome_screen.dart';

/// Temporary screen shown after a successful login + OTP.
/// Replace it with the real home page later.
class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final name = AuthService.instance.currentUserName;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 72, color: AppColors.brown),
                const SizedBox(height: 16),
                Text(
                  name == null ? 'تم تسجيل الدخول' : 'أهلاً $name',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brownDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'تم تسجيل دخولك بنجاح. هذه صفحة مؤقتة، سنستبدلها بالصفحة الرئيسية.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.hint),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    AuthService.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const WelcomeScreen()),
                      (_) => false,
                    );
                  },
                  child: const Text('تسجيل الخروج'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
