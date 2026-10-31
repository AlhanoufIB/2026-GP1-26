import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/otp_input.dart';
import '../widgets/primary_button.dart';
import 'home_placeholder.dart';

/// Screen 2 of the mockups: "التحقق من رقم الجوال".
/// Opened ONLY after a correct phone + password on the login screen.
class OtpScreen extends StatefulWidget {
  final String phone; // +9665XXXXXXXX

  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _resendSeconds = 60;

  final _otpKey = GlobalKey<OtpInputState>();
  String _code = '';
  String? _error;
  bool _verifying = false;
  bool _resending = false;
  int _secondsLeft = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) t.cancel();
      if (mounted) setState(() => _secondsLeft--);
    });
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _verify() async {
    if (_verifying) return;
    FocusScope.of(context).unfocus();

    if (_code.length != 6) {
      setState(() => _error = 'أدخل الرمز المكوّن من ٦ أرقام');
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      final ok = await AuthService.instance.verifyOtp(_code);
      if (!mounted) return;
      if (!ok) {
        setState(() => _error = 'الرمز غير صحيح، لم يتم تسجيل دخولك');
        _otpKey.currentState?.clear();
        return;
      }
      // Correct code: the user is logged in. Remove all login pages from the
      // back stack so "back" can't return to them.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePlaceholder()),
        (_) => false,
      );
    } catch (_) {
      _snack('حدث خطأ، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await AuthService.instance.sendOtp(widget.phone);
      _otpKey.currentState?.clear();
      _error = null;
      _startTimer();
      _snack('تم إرسال رمز جديد');
    } catch (_) {
      _snack('تعذّر إرسال الرمز، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  String get _timerText {
    final s = _secondsLeft.clamp(0, _resendSeconds).toInt();
    final mm = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft <= 0 && !_resending;
      // Wrap the phone number so it stays left-to-right inside Arabic text
    final lri = String.fromCharCode(0x2066); // left-to-right isolate
    final pdi = String.fromCharCode(0x2069); // end of isolate
    final phoneText = '$lri${formatPhone(widget.phone)}$pdi';

    const linkStyle = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w800,
      color: AppColors.brownDark,
      decoration: TextDecoration.underline,
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),

                      // "رجوع" link at the top
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'رجوع',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brownDark,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward,
                                    size: 16, color: AppColors.brownDark),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      const Text(
                        'التحقق من رقم الجوال',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brownDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'أدخل الرمز المكوّن من ٦ أرقام المرسل إلى $phoneText',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.7,
                          color: AppColors.hint,
                        ),
                      ),
                      const SizedBox(height: 28),

                      OtpInput(
                        key: _otpKey,
                        hasError: _error != null,
                        onChanged: (v) => setState(() {
                          _code = v;
                          if (_error != null && v.isNotEmpty) _error = null;
                        }),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.error,
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Text(
                            'لم يصلك الرمز؟',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.hint,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (canResend)
                            GestureDetector(
                              onTap: _resend,
                              child: const Text('أعد الإرسال', style: linkStyle),
                            )
                          else
                            Text('أعد الإرسال بعد $_timerText',
                                style: linkStyle),
                        ],
                      ),

                      // Development hint only. It is NOT shown in release
                      // builds or once the mock service is replaced.
                      if (kDebugMode &&
                          AuthService.instance is MockAuthService) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.gradientStart
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'وضع التجربة: الرمز الصحيح هو 123456',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.brownDark,
                            ),
                          ),
                        ),
                      ],

                      const Spacer(),
                      const SizedBox(height: 20),
                      const Text(
                        'إذا كان الرمز خاطئاً فلن يتم تسجيل دخولك وسنخبرك بذلك.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.hint,
                        ),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        text: 'تحقق و سجل الدخول',
                        loading: _verifying,
                        onPressed: _verify,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
