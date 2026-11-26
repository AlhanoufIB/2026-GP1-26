import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../repositories/business_requirement_repository.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/labeled_field.dart';
import '../../widgets/primary_button.dart';
import '../map/heatmap_data.dart' show loadDatasetPoints;
// same lists as the add-property form, so both sides pick the same values
import '../property_management/property_form_screen.dart'
    show kActivityByType, kPropertyTypes;
import 'recommendations_screen.dart';

/// Kept only for the repository's method signature; the real owner id
/// is taken from Firebase Auth (auth.uid) when saving.
const String kCurrentBusinessOwnerId = 'business_owner_1';

/// "أخبرنا عن نشاطك التجاري" — collects requirements for recommendations.
class BusinessInfoScreen extends StatefulWidget {
  const BusinessInfoScreen({super.key});

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final _formKey = GlobalKey<FormState>(); // lets us validate all fields
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _spaceController = TextEditingController();
  final _otherController = TextEditingController();
  final _locationFocus = FocusNode();
  String? _propertyType; // نوع العقار (dropdown)
  String? _businessType; // نوع النشاط (dropdown, depends on the type)
  List<String> _districts = []; // Riyadh districts from the heat map data
  bool _saving = false;

  /// Activities allowed for the chosen property type.
  List<String> get _activityOptions =>
      kActivityByType[_propertyType] ?? const <String>[];

  @override
  void initState() {
    super.initState();
    _prefillFromLastTime();
    _loadDistricts();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _locationFocus.dispose();
    _budgetController.dispose();
    _spaceController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  /// If the owner filled the form before, show their previous answers.
  Future<void> _prefillFromLastTime() async {
    final last = await BusinessRequirementRepository.instance.getLatest(
      kCurrentBusinessOwnerId,
    );
    if (last == null || !mounted) return;
    setState(() {
      if (kPropertyTypes.contains(last.propertyType)) {
        _propertyType = last.propertyType;
        if (_activityOptions.contains(last.businessType)) {
          _businessType = last.businessType;
        }
      }
    });
    _locationController.text = last.preferredLocation ?? '';
    _budgetController.text = last.budget.toInt().toString();
    _spaceController.text = last.requiredSpace.toInt().toString();
    _otherController.text = last.otherRequirements ?? '';
  }

  /// Reads the 164 district names from the heat map dataset (no duplicates).
  Future<void> _loadDistricts() async {
    try {
      final points = await loadDatasetPoints();
      final names = {
        for (final p in points)
          if (p.district != null && p.district!.trim().isNotEmpty)
            p.district!.trim(),
      }.toList()
        ..sort();
      if (mounted) setState(() => _districts = names);
    } catch (_) {
      // no list -> the field still works as normal typing
    }
  }

  // ---------- validation ----------

  static double? _parseNumber(String? text) =>
      double.tryParse(toWesternDigits(text?.trim() ?? ''));

  static final _lettersOnly = RegExp(r'^[a-zA-Z\u0621-\u064A ]+$');

  String? _validateLocation(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return null; // optional
    if (!_lettersOnly.hasMatch(value)) {
      return 'الحي يجب أن يحتوي على أحرف فقط';
    }
    if (value.length < 2) return 'اكتب حرفين على الأقل';
    return null;
  }

  String? _validateBudget(String? v) {
    if (v == null || v.trim().isEmpty) return 'الرجاء إدخال الميزانية';
    final n = _parseNumber(v);
    if (n == null) return 'أدخل رقماً صحيحاً';
    if (n <= 0) return 'الميزانية يجب أن تكون أكبر من 0';
    return null;
  }

  String? _validateSpace(String? v) {
    if (v == null || v.trim().isEmpty) return 'الرجاء إدخال المساحة';
    final n = _parseNumber(v);
    if (n == null) return 'أدخل رقماً صحيحاً';
    if (n <= 0) return 'المساحة يجب أن تكون أكبر من 0 م²';
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
        businessType: _businessType!,
        propertyType: _propertyType!,
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
        ..showSnackBar(
          const SnackBar(content: Text('تعذّر حفظ المتطلبات، حاول مرة أخرى')),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final letters = FilteringTextInputFormatter.allow(
      RegExp(r'[a-zA-Z\u0621-\u064A ]'),
    );
    List<TextInputFormatter> digits(int max) => [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
          LengthLimitingTextInputFormatter(max),
        ];

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          // errors appear while typing, and disappear once fixed
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              // نوع العقار + نوع النشاط (same lists as add-property)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('نوع العقار *'),
                        AppDropdownField(
                          value: _propertyType,
                          hint: 'محل، مكتب، أرض',
                          items: kPropertyTypes,
                          onChanged: (v) => setState(() {
                            _propertyType = v;
                            _businessType = null; // list changes with the type
                          }),
                          validator: (v) =>
                              v == null ? 'نوع العقار مطلوب' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('نوع النشاط *'),
                        AppDropdownField(
                          key: ValueKey(_propertyType), // reset on type change
                          value: _businessType,
                          hint: _propertyType == null
                              ? 'اختر نوع العقار أولاً'
                              : 'مقهى، مطعم،...',
                          items: _activityOptions,
                          onChanged: _propertyType == null
                              ? null // disabled until a type is chosen
                              : (v) => setState(() => _businessType = v),
                          validator: (v) =>
                              v == null ? 'نوع النشاط مطلوب' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // الحي: pick from the list or type your own
              _label('الحي المفضّل'),
              RawAutocomplete<String>(
                textEditingController: _locationController,
                focusNode: _locationFocus,
                // empty -> show all districts; typing -> only the matches
                optionsBuilder: (value) {
                  final q = value.text.trim();
                  if (q.isEmpty) return _districts;
                  return _districts.where((d) => d.contains(q));
                },
                fieldViewBuilder: (context, controller, focusNode, _) =>
                    TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  inputFormatters: [
                    letters,
                    LengthLimitingTextInputFormatter(40),
                  ],
                  validator: _validateLocation,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.brownDark),
                  decoration:
                      appInputDecoration('اختر من القائمة أو اكتب الحي')
                          .copyWith(
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                optionsViewBuilder: (context, onSelected, options) => Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 240,
                        maxWidth: MediaQuery.of(context).size.width - 40,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, i) {
                          final d = options.elementAt(i);
                          return ListTile(
                            dense: true,
                            title: Text(d),
                            onTap: () => onSelected(d),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // الميزانية + المساحة
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LabeledField(
                      label: 'الميزانية السنوية (ر.س) *',
                      hint: 'الحد الأعلى',
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: digits(8),
                      validator: _validateBudget,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: LabeledField(
                      label: 'المساحة المطلوبة (م²) *',
                      hint: 'الحد الأدنى',
                      controller: _spaceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: digits(6),
                      validator: _validateSpace,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              LabeledField(
                label: 'متطلبات أخرى',
                hint: 'مواقف، واجهة على الشارع',
                controller: _otherController,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: PrimaryButton(
              text: 'عرض الترشيحات',
              loading: _saving,
              onPressed: _submit,
            ),
          ),
          const AppBottomNav(current: AppTab.explore),
        ],
      ),
    );
  }

  /// Same label style as LabeledField, for the dropdowns and the district.
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.brownDark,
          ),
        ),
      );

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
              Text(
                'رجوع',
                style: TextStyle(
                  color: AppColors.brown,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'أخبرنا عن نشاطك التجاري',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.brownDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'نرتّب لك العقارات حسب مدى ملاءمتها لمتطلباتك.',
          style: TextStyle(fontSize: 14, color: AppColors.hint),
        ),
        const SizedBox(height: 10),
        const Text(
          '* حقول مطلوبة',
          style: TextStyle(fontSize: 12, color: AppColors.error),
        ),
      ],
    );
  }
}