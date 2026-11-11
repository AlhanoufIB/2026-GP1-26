import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../authentication/welcome_screen.dart';

/// Local palette for the onboarding illustrations (matches the Figma frames).
class _C {
  static const card = Color(0xFFEDE5D5);
  static const tan = Color(0xFFC9A27A);
  static const tanLight = Color(0xFFDCC9AA);
  static const tanSoft = Color(0xFFEBDDC6);
  static const brownDeep = Color(0xFF664832);
  static const green = Color(0xFF2E6B52);
  static const textDark = Color(0xFF2B211C);
  static const textGrey = Color(0xFF8A7F77);
  static const line = Color(0xFFE0D3BC);
}

class _OnboardingData {
  final String title;
  final String description;
  final Widget Function() illustration;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.illustration,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  late final List<_OnboardingData> _pages = [
    _OnboardingData(
      title: 'الخريطة التفاعلية',
      description:
          'اعرف أين يتركّز الطلب على العقارات التجارية في أحياء الرياض، واختر الموقع المناسب لنشاطك بنظرة واحدة.',
      illustration: () => const _MapIllustration(),
    ),
    _OnboardingData(
      title: 'ترشيحات ذكية تناسب نشاطك',
      description:
          'أخبرنا بنوع نشاطك وميزانيتك، ويرشّح لك الذكاء الاصطناعي أفضل العقارات مع نسبة توافق، ويمكنك حفظها ومقارنتها.',
      illustration: () => const _RecommendationsIllustration(),
    ),
    _OnboardingData(
      title: 'تواصل مباشر وأضف عقارك',
      description:
          'تحدّث مع المالك أو المستأجر مباشرة، وأضف عقارك واحصل على تقدير للإيجار المناسب بالذكاء الاصطناعي.',
      illustration: () => const _ChatPriceIllustration(),
    ),
  ];

  bool get _isLast => _page == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// "تخطي" -> straight to the home page.
  void _skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  /// Last page "ابدأ الآن" -> welcome / login / sign up flow.
  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              _buildProgress(),
              const SizedBox(height: 8),
              _buildSkip(),
              const SizedBox(height: 8),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  reverse: true, // RTL: first page is on the right
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
                ),
              ),
              const SizedBox(height: 12),
              _buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
  return Row(
    children: [
      Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          '${_page + 1}/${_pages.length}',
          style: const TextStyle(fontSize: 11, color: _C.textGrey),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Directionality(
          textDirection: TextDirection.ltr, // first segment on the left
          child: Row(
            children: [
              for (int i = 0; i < _pages.length; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= _page ? _C.brownDeep : _C.tanLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                if (i != _pages.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ),
      ),
    ],
  );
}
  Widget _buildSkip() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Visibility(
        visible: !_isLast,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: TextButton(
          onPressed: _skip,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'تخطي',
            style: TextStyle(
              fontSize: 13,
              color: _C.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _next,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brown,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          _isLast ? 'ابدأ الآن' : 'التالي',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ───────────────────────── Page body ─────────────────────────

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 268 / 236,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(color: _C.card, child: data.illustration()),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _C.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.9,
              color: _C.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Illustration 1: map ─────────────────────────

class _MapIllustration extends StatelessWidget {
  const _MapIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MapPainter(), size: Size.infinite);
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;

    // Grid lines
    final grid = Paint()
      ..color = _C.line
      ..strokeWidth = 1.2;
    for (final x in [0.35, 0.69]) {
      canvas.drawLine(Offset(w * x, 0), Offset(w * x, h), grid);
    }
    for (final y in [0.3, 0.64]) {
      canvas.drawLine(Offset(0, h * y), Offset(w, h * y), grid);
    }

    // Diagonal road
    final road = Paint()
      ..color = const Color(0xFFE4D2B4)
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-4, h * 0.97), Offset(w + 4, h * 0.1), road);

    // Heat circles
    canvas.drawCircle(
      Offset(w * 0.37, h * 0.35),
      w * 0.22,
      Paint()..color = const Color(0xFFD9A79A).withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      Offset(w * 0.37, h * 0.35),
      w * 0.11,
      Paint()..color = const Color(0xFFC4776A),
    );
    canvas.drawCircle(
      Offset(w * 0.8, h * 0.19),
      w * 0.1,
      Paint()..color = const Color(0xFFA9B8A2),
    );
    canvas.drawCircle(
      Offset(w * 0.64, h * 0.68),
      w * 0.18,
      Paint()..color = const Color(0xFFDDB88E).withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset(w * 0.64, h * 0.68),
      w * 0.08,
      Paint()..color = const Color(0xFFA98C67),
    );

    // Pin
    final c = Offset(w * 0.5, h * 0.5);
    final pin = Paint()..color = _C.brownDeep;
    canvas.drawCircle(c, 11, pin);
    final tip = Path()
      ..moveTo(c.dx - 9, c.dy + 6)
      ..lineTo(c.dx, c.dy + 26)
      ..lineTo(c.dx + 9, c.dy + 6)
      ..close();
    canvas.drawPath(tip, pin);
    canvas.drawCircle(c, 4.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ───────────────────── Illustration 2: recommendations ─────────────────────

class _RecommendationsIllustration extends StatelessWidget {
  const _RecommendationsIllustration();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ResultCard(
            percent: '92%',
            pillColor: _C.green,
            thumbColor: _C.tan,
            borderColor: _C.brownDeep,
            borderWidth: 2,
            height: 60,
          ),
          const SizedBox(height: 14),
          _ResultCard(
            percent: '84%',
            pillColor: _C.tan,
            thumbColor: _C.tanSoft,
            borderColor: _C.line,
            borderWidth: 1.2,
            height: 58,
          ),
          const SizedBox(height: 14),
          Opacity(
            opacity: 0.6,
            child: _ResultCard(
              percent: null,
              pillColor: _C.tanSoft,
              thumbColor: _C.tanSoft,
              borderColor: _C.line,
              borderWidth: 1.2,
              height: 46,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String? percent;
  final Color pillColor;
  final Color thumbColor;
  final Color borderColor;
  final double borderWidth;
  final double height;

  const _ResultCard({
    required this.percent,
    required this.pillColor,
    required this.thumbColor,
    required this.borderColor,
    required this.borderWidth,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Row(
        children: [
          Container(
            width: height - 20,
            height: height - 20,
            decoration: BoxDecoration(
              color: thumbColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 5,
                  width: 86,
                  decoration: BoxDecoration(
                    color: percent == null ? _C.tanLight : _C.brownDeep,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  height: 4,
                  width: 56,
                  decoration: BoxDecoration(
                    color: _C.tanLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: percent == null
                ? null
                : Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      percent!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── Illustration 3: chat + price ─────────────────────

class _ChatPriceIllustration extends StatelessWidget {
  const _ChatPriceIllustration();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Received bubble (left)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 148,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    width: 100,
                    decoration: BoxDecoration(
                      color: _C.tanLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: _C.tanLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Sent bubble (right)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 150,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: _C.brownDeep,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    width: 102,
                    decoration: BoxDecoration(
                      color: _C.tanSoft,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 4,
                    width: 70,
                    decoration: BoxDecoration(
                      color: _C.tan,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Price estimate card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.brownDeep, width: 1.6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'سعر الإيجار المقدّر',
                  style: TextStyle(fontSize: 9, color: _C.textGrey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      '76,000 ر.س',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _C.textDark,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _C.green,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'سنوياً',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'النطاق المعتاد: 70,000 – 83,000 ر.س',
                  style: TextStyle(fontSize: 9, color: _C.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}