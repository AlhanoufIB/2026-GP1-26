import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

// Screen 1 of the mockups: the first page of the app.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final heroHeight = constraints.maxHeight * 0.52;

          return Column(
            children: [
              // ---------- Hero (gradient + skyline + logo) ----------
              SizedBox(
                height: heroHeight,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(36)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF3E8D9), Color(0xFFCDAA84)],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(bottom: Radius.circular(36)),
                    child: Stack(
                      children: [
                        // City skyline at the bottom of the hero
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: heroHeight * 0.58,
                          child: CustomPaint(painter: _SkylinePainter()),
                        ),
                        // Logo + name
                        Padding(
                          padding: EdgeInsets.only(top: topInset),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Soft glass circle behind the logo
                                Container(
                                  width: 168,
                                  height: 168,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.28),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.45),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Container(
                                    width: 112,
                                    height: 112,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFBF5EE),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.brownDark
                                              .withValues(alpha: 0.18),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    // >>> YOUR LOGO GOES HERE (see
                                    // lib/constants/app_assets.dart)
                                    child: const AppLogo(
                                      size: 88,
                                      showLabel: false,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'مُلّاك',
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brownDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ---------- Text + buttons ----------
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 16),
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
                            fontSize: 13,
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
                        const SizedBox(height: 12),
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

/// Draws simple translucent buildings with windows (the skyline in the hero).
/// If you get a real background image later, delete this painter and put an
/// Image there instead.
class _SkylinePainter extends CustomPainter {
  // [x, width, height] as fractions of the available area
  static const _buildings = <List<double>>[
    [0.00, 0.17, 0.42],
    [0.14, 0.17, 0.66],
    [0.30, 0.15, 0.34],
    [0.58, 0.18, 0.56],
    [0.75, 0.13, 0.38],
    [0.87, 0.15, 0.70],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = AppColors.brownDark.withValues(alpha: 0.17);
    final window = Paint()..color = Colors.white.withValues(alpha: 0.5);

    for (final b in _buildings) {
      final left = b[0] * size.width;
      final width = b[1] * size.width;
      final height = b[2] * size.height;
      final top = size.height - height;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(left, top, width, height),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        body,
      );

      // Windows grid
      const win = 6.0;
      const step = 14.0;
      final cols = ((width - 12) / step).floor().clamp(1, 4).toInt();
      final startX = left + (width - (cols * step - (step - win))) / 2;
      for (var y = top + 12; y < size.height - 12; y += step) {
        for (var c = 0; c < cols; c++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(startX + c * step, y, win, win),
              const Radius.circular(1.5),
            ),
            window,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
