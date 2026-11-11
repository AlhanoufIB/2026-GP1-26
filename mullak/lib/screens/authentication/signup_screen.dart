import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import 'widgets/app_logo.dart';
import 'widgets/bottom_switch_link.dart';
import 'widgets/labeled_field.dart';
import 'widgets/primary_button.dart';
import 'login_screen.dart';

/// Screen 4 of the Figma.
/// Flow: create the account  ->  go back to LOGIN (the user is NOT logged in).
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = AuthService.instance;
    final phone = normalizePhone(_phoneCtrl.text);

    try {
      if (await auth.phoneExists(phone)) {
        _snack('هذا الرقم مسجّل مسبقاً، سجّل الدخول بدلاً من ذلك');
        return;
      }
      await auth.signUp(
        name: _nameCtrl.text.trim(),
        phone: phone,
        password: _passCtrl.text,
      );
      if (!mounted) return;
      // Account created -> the user must now LOG IN (no auto login).
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            initialPhone: phone,
            showRegisteredNotice: true,
          ),
        ),
        (route) => route.isFirst, // keep the welcome page underneath
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
                        const SizedBox(height: 18),

                        const Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brownDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'حساب واحد يمكّنك من البحث عن عقار مناسب لنشاطك، وعرض عقاراتك للإيجار.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.7,
                            color: AppColors.hint,
                          ),
                        ),
                        const SizedBox(height: 22),

                        LabeledField(
                          label: 'الاسم الكامل',
                          hint: 'اكتب اسمك الكامل',
                          controller: _nameCtrl,
                          validator: (v) => (v == null || v.trim().length < 3)
                              ? 'الرجاء إدخال الاسم الكامل'
                              : null,
                        ),
                        const SizedBox(height: 14),
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
                          hint: '٨ خانات على الأقل',
                          controller: _passCtrl,
                          isPassword: true,
                          validator: validatePassword,
                        ),
                        const SizedBox(height: 14),
                        LabeledField(
                          label: 'تأكيد كلمة المرور',
                          hint: 'أعد كتابة كلمة المرور',
                          controller: _confirmCtrl,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'الرجاء تأكيد كلمة المرور';
                            }
                            if (v != _passCtrl.text) {
                              return 'كلمتا المرور غير متطابقتين';
                            }
                            return null;
                          },
                        ),

                        const Spacer(),
                        const SizedBox(height: 24),

                        PrimaryButton(
                          text: 'إنشاء الحساب',
                          loading: _loading,
                          onPressed: _signUp,
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: BottomSwitchLink(
                            question: 'لديك حساب؟',
                            actionText: 'تسجيل الدخول',
                            onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
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