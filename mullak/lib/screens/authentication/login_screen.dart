import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import 'widgets/app_logo.dart';
import 'widgets/bottom_switch_link.dart';
import 'widgets/labeled_field.dart';
import 'widgets/primary_button.dart';
import 'otp_screen.dart';
import 'signup_screen.dart';

/// Screen 3 of the Figma.
/// Flow: phone + password  ->  (if correct)  OTP screen  ->  home.
class LoginScreen extends StatefulWidget {
  /// Pre-fills the phone field (used right after sign-up).
  final String? initialPhone;

  /// Shows "account created, please log in" when opened after sign-up.
  final bool showRegisteredNotice;

  const LoginScreen({
    super.key,
    this.initialPhone,
    this.showRegisteredNotice = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneCtrl;
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(
      text: widget.initialPhone == null
          ? ''
          : formatPhone(widget.initialPhone!),
    );
    if (widget.showRegisteredNotice) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _snack('تم إنشاء حسابك بنجاح، سجّل الدخول للمتابعة');
      });
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = AuthService.instance;
    final phone = normalizePhone(_phoneCtrl.text);

    try {
      // 1) phone + password must match an account
      final ok = await auth.checkCredentials(
        phone: phone,
        password: _passCtrl.text,
      );
      if (!ok) {
        _snack('رقم الجوال أو كلمة المرور غير صحيحة');
        return;
      }
      // 2) "send" the one-time code, then open the OTP page
      await auth.sendOtp(phone);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OtpScreen(phone: phone)),
      );
    } catch (_) {
      _snack('حدث خطأ، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // "رجوع" on the right, logo on the left
                        const AuthTopBar(),

                        // Figma leaves a big gap here on the login page
                        const SizedBox(height: 90),

                        const Text(
                          'أهلاً بعودتك',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brownDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'سجّل الدخول برقم الجوال وكلمة المرور، وسنرسل لك رمز تحقق لمرة واحدة.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.7,
                            color: AppColors.hint,
                          ),
                        ),
                        const SizedBox(height: 26),

                        LabeledField(
                          label: 'رقم الجوال',
                          hint: '+966 5X XXX XXXX',
                          controller: _phoneCtrl,
                          forceLtr: true,
                          keyboardType: TextInputType.phone,
                          validator: validatePhone,
                        ),
                        const SizedBox(height: 14),
                        LabeledField(
                          label: 'كلمة المرور',
                          hint: 'كلمة المرور',
                          controller: _passCtrl,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: validatePassword,
                        ),

                        const Spacer(),
                        const SizedBox(height: 24),

                        PrimaryButton(
                          text: 'تسجيل الدخول',
                          loading: _loading,
                          onPressed: _login,
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: BottomSwitchLink(
                            question: 'مستخدم جديد؟',
                            actionText: 'إنشاء حساب',
                            onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
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