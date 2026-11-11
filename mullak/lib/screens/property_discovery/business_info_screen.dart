import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../repositories/business_requirement_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/primary_button.dart';
import 'recommendations_screen.dart';

/// TEMPORARY until real auth: the logged-in business owner's id.
const String kCurrentBusinessOwnerId = 'business_owner_1';

/// "أخبرنا عن نشاطك التجاري" — collects requirements for recommendations.
class BusinessInfoScreen extends StatefulWidget {
  const BusinessInfoScreen({super.key});

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final _formKey = GlobalKey<FormState>(); // lets us validate all fields
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _spaceController = TextEditingController();
  final _otherController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _prefillFromLastTime();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _spaceController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  /// If the owner filled the form before, show their previous answers.
  Future<void> _prefillFromLastTime() async {
    final last = await BusinessRequirementRepository.instance
        .getLatest(kCurrentBusinessOwnerId);
    if (last == null || !mounted) return;
    _typeController.text = last.businessType;
    _locationController.text = last.preferredLocation ?? '';
    _budgetController.text = last.budget.toInt().toString();
    _spaceController.text = last.requiredSpace.toInt().toString();
    _otherController.text = last.otherRequirements ?? '';
  }

  // ---------- validation ----------

  /// Turns Arabic digits into English ones: "٧٨٠٠٠" -> "78000"
  static String _toEnglishDigits(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    final buffer = StringBuffer();
    for (final ch in input.split('')) {
      final i = arabic.indexOf(ch);
      buffer.write(i == -1 ? ch : i.toString());
    }
    return buffer.toString();
  }

  static double? _parseNumber(String? text) =>
      double.tryParse(_toEnglishDigits(text?.trim() ?? ''));

  String? _validateRequiredText(String? value) {
    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
    return null; // null = valid
  }

  String? _validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'مطلوب';
    final number = _parseNumber(value);
    if (number == null) return 'أدخل رقماً صحيحاً';
    if (number <= 0) return 'يجب أن يكون أكبر من صفر';
    return null;
  }

  // ---------- submit ----------

  Future<void> _submit() async {
    FocusScope.of(context).unfocus(); // close the keyboard
    if (!_formKey.currentState!.validate()) return; // shows red errors

    setState(() => _saving = true);
    try {
      final location = _locationController.text.trim();
      final other = _otherController.text.trim();
      final requirement = await BusinessRequirementRepository.instance.save(
        businessOwnerId: kCurrentBusinessOwnerId,
        businessType: _typeController.text.trim(),
        budget: _parseNumber(_budgetController.text)!,
        requiredSpace: _parseNumber(_spaceController.text)!,
        preferredLocation: location.isEmpty ? null : location,
        otherRequirements: other.isEmpty ? null : other,
      );
      if (!mounted) return;
      // open the recommendations for the requirement we just saved
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecommendationsScreen(requirement: requirement),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
            content: Text('تعذّر حفظ المتطلبات، حاول مرة أخرى')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final numberInput = [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')), // digits only
    ];

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              LabeledField(
                label: 'نوع النشاط',
                hint: 'مثال: مقهى',
                controller: _typeController,
                validator: _validateRequiredText,
              ),
              const SizedBox(height: 18),
              LabeledField(
                label: 'الموقع المفضّل',
                hint: 'الحي أو المنطقة في الرياض',
                controller: _locationController,
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LabeledField(
                      label: 'الميزانية السنوية (ر.س)',
                      hint: 'الحد الأعلى',
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: numberInput,
                      validator: _validatePositiveNumber,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: LabeledField(
                      label: 'المساحة المطلوبة (م²)',
                      hint: 'الحد الأدنى',
                      controller: _spaceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: numberInput,
                      validator: _validatePositiveNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              LabeledField(
                label: 'متطلبات أخرى',
                hint: 'مواقف، واجهة على الشارع',
                controller: _otherController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: PrimaryButton(
            text: 'عرض الترشيحات',
            loading: _saving,
            onPressed: _submit,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: AppColors.brown, size: 18),
              SizedBox(width: 4),
              Text('رجوع',
                  style: TextStyle(
                      color: AppColors.brown, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'أخبرنا عن نشاطك التجاري',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.brownDark),
        ),
        const SizedBox(height: 6),
        const Text(
          'نرتّب لك العقارات حسب مدى ملاءمتها لمتطلباتك.',
          style: TextStyle(fontSize: 14, color: AppColors.hint),
        ),
      ],
    );
  }
}