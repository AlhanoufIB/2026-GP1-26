import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'widgets/app_logo.dart';
import 'widgets/primary_button.dart';
import 'widgets/secondary_button.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

/// Screen 1 of the Figma: the first page of the app.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// Color of the rounded square that holds the logo.
  static const _tileColor = Color(0xFFF7F0E6);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final heroHeight = constraints.maxHeight * 0.47;

          return Column(
            children: [
              // ---------- Hero: gradient + circles + logo ----------
              SizedBox(
                height: heroHeight,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(32)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF1E5D4), Color(0xFFC9A57F)],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12, topInset + 8, 12, 12),
                    child: const Center(
                      // Shrinks everything on very short screens.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _LogoBadge(),
                      ),
                    ),
                  ),
                ),
              ),

              // ---------- Text + buttons ----------
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 52, 20, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'عقارك التجاري المناسب، بذكاء',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brownDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'نربط أصحاب الأنشطة التجارية بمُلّاك العقارات التجارية في الرياض، ونرشّح لك الأنسب بالذكاء الاصطناعي.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.7,
                            color: AppColors.hint,
                          ),
                        ),
                        const Spacer(),
                        PrimaryButton(
                          text: 'تسجيل الدخول',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SecondaryButton(
                          text: 'إنشاء حساب',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Two soft circles with the logo in a rounded square in the middle.
class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 236,
      height: 236,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer soft circle
          Container(
            width: 236,
            height: 236,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          // Inner soft circle
          Container(
            width: 196,
            height: 196,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          // Rounded square with the logo
          Container(
            width: 144,
            height: 144,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: WelcomeScreen._tileColor,
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brownDark.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            // >>> YOUR LOGO (see lib/constants/app_assets.dart)
            child: const AppLogo(
              size: 100,
              blendColor: WelcomeScreen._tileColor,
            ),
          ),
        ],
      ),
    );
  }
}