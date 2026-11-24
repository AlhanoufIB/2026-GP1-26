import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../../models/property_myProperty.dart';
import '../../services/property_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/back_link.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/image_picker_section.dart';
import 'location_picker_screen.dart';
import 'suggested_price_screen.dart';

/// قوائم مشتقة من QI_Neighborhood_Data.xlsx:
///  أنواع العقار ← Rental Commercial + Parcel Types
///  أنواع النشاط ← تصنيفات Land Use (Food/Medical/Educational/Entertainment/Sports/Commercial)
const Map<String, List<String>> kActivityByType = {
  'محل': ['مقهى', 'مطعم', 'بقالة / سوبرماركت', 'ملابس وأزياء', 'صيدلية', 'صالون وخدمات تجميل', 'خدمات تجارية أخرى'],
  'مكتب': ['مكتب إداري', 'مكتب خدمات', 'عيادة', 'مركز تدريب وتعليم'],
  'معرض': ['معرض سيارات', 'معرض أثاث', 'معرض تجاري عام'],
  'مبنى تجاري': ['مجمع تجاري', 'مركز طبي', 'مرافق تعليمية', 'ترفيه', 'رياضة'],
  'مبنى تجاري سكني': ['مكاتب وشقق', 'محلات ومكاتب'],
  'دور': ['مكاتب', 'عيادات', 'مطعم / مقهى'],
  'أرض تجارية': ['بناء مشروع تجاري', 'موقف سيارات'],
};
final List<String> kPropertyTypes = kActivityByType.keys.toList();

class PropertyFormScreen extends StatefulWidget {
  /// null = إضافة عقار جديد، غير null = تعديل
  final Property? property;
  const PropertyFormScreen({super.key, this.property});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _type;
  String? _activity;

  // لو العقار القديم نوعه/نشاطه مو في القائمة نضيفه عشان ما يختفي
  List<String> get _typeOptions => [
        ...kPropertyTypes,
        if (_type != null && !kPropertyTypes.contains(_type)) _type!,
      ];
  List<String> get _activityOptions => [
        ...(kActivityByType[_type] ?? const <String>[]),
        if (_activity != null &&
            !(kActivityByType[_type] ?? const <String>[]).contains(_activity))
          _activity!,
      ];

  late final TextEditingController _title;
  late final TextEditingController _area;
  late final TextEditingController _district;
  late final TextEditingController _address;
  late final TextEditingController _price;
  late final TextEditingController _description;
  final _priceFocus = FocusNode();

  List<String> _images = [];
  int _mainImage = 0;
  LatLng? _latLng;
  bool _hasParking = false;
  double? _estimated;
  bool _saving = false;
  bool _submitted = false;

  bool get _isEdit => widget.property != null;

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _type = (p?.propertyType.isEmpty ?? true) ? null : p!.propertyType;
    _activity = (p?.activityType?.isEmpty ?? true) ? null : p!.activityType;
    _title = TextEditingController(text: p?.title ?? '');
    _area = TextEditingController(text: p?.areaSqm.round().toString() ?? '');
    _district = TextEditingController(text: p?.district ?? '');
    _address = TextEditingController(text: p?.address ?? '');
    _price = TextEditingController(text: p?.rentPrice.round().toString() ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _images = [...?p?.images.map((i) => i.imageUrl)];
    _hasParking = p?.hasParking ?? false;
    _estimated = p?.estimatedPrice;
    if (p != null) _latLng = LatLng(p.latitude, p.longitude);
  }

  @override
  void dispose() {
    _title.dispose();
    _area.dispose();
    _district.dispose();
    _address.dispose();
    _price.dispose();
    _description.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String? _requiredText(String? v, String msg) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  String? _requiredNumber(String? v, String msg) {
    if (v == null || v.trim().isEmpty) return msg;
    final n = int.tryParse(v.trim());
    return (n == null || n <= 0) ? 'أدخل رقماً صحيحاً' : null;
  }

  Future<void> _suggestPrice() async {
    final area = int.tryParse(_area.text.trim());
    if (_type == null || area == null || area <= 0) {
      _showMessage('أدخل نوع العقار والمساحة أولاً لنقترح لك سعراً');
      return;
    }

    final choice = await Navigator.push<PriceChoice>(
      context,
      MaterialPageRoute(
        builder: (_) => SuggestedPriceScreen(
          type: _type!,
          area: area,
          district: _district.text.trim(),
        ),
      ),
    );
    if (choice == null) return;

    setState(() => _estimated = choice.estimated.toDouble());

    if (choice.price != null) {
      setState(() => _price.text = choice.price.toString());
    } else {
      setState(() => _price.clear());
      _priceFocus.requestFocus();
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => LocationPickerScreen(initial: _latLng)),
    );
    if (result != null) setState(() => _latLng = result);
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    final fieldsOk = _formKey.currentState!.validate();
    final extraOk = _type != null && _latLng != null;
    if (!fieldsOk || !extraOk) {
      _showMessage('يرجى تعبئة جميع الحقول المطلوبة');
      return;
    }

    final area = int.parse(_area.text.trim());
    final price = int.parse(_price.text.trim());

    setState(() => _saving = true);
    try {
      final old = widget.property;
      final property = Property(
        id: old?.id ?? '',
        title: _title.text.trim(), // يكتبه المستخدم
        propertyType: _type!,
        activityType: _activity,
        areaSqm: area.toDouble(),
        district: _district.text.trim(),
        city: old?.city ?? kDefaultCity,
        rentPrice: price.toDouble(),
        status: old?.status ?? 'available',
        latitude: _latLng!.latitude,
        longitude: _latLng!.longitude,
        estimatedPrice: _estimated,
        address: _address.text.trim(),
        description: _description.text.trim(),
        hasParking: _hasParking,
      );

      if (_isEdit) {
        await PropertyService.instance.updateProperty(property,
            imagePaths: _images, mainIndex: _mainImage);
      } else {
        await PropertyService.instance.createProperty(property,
            imagePaths: _images, mainIndex: _mainImage);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e, st) {
      debugPrint('SAVE ERROR: $e\n$st');
      _showMessage('تعذّر الحفظ، تأكد من الإنترنت وحاول مرة ثانية');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.digitsOnly];
    final mapError = _submitted && _latLng == null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BackLink(text: 'عقاراتي'),
                      const SizedBox(height: 10),
                      Text(
                        _isEdit ? 'تعديل العقار' : 'إضافة عقار',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const RequiredNote(),

                      // 1) العنوان
                      const FormFieldLabel('عنوان العقار', required: true),
                      AppTextField(
                        controller: _title,
                        hint: 'العنوان',
                        validator: (v) => _requiredText(v, 'العنوان مطلوب'),
                      ),

                      // 2) المساحة
                      const FormFieldLabel('المساحة (م²)', required: true),
                      AppTextField(
                        controller: _area,
                        hint: 'مثال: 85',
                        keyboardType: TextInputType.number,
                        inputFormatters: digits,
                        validator: (v) => _requiredNumber(v, 'المساحة مطلوبة'),
                      ),

                      // 3+4) نوع العقار + نوع النشاط (يعتمد على النوع)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const FormFieldLabel('نوع العقار',
                                    required: true),
                                AppDropdownField(
                                  value: _type,
                                  hint: 'محل، مكتب، أرض',
                                  items: _typeOptions,
                                  onChanged: (v) => setState(() {
                                    _type = v;
                                    _activity = null;
                                  }),
                                  validator: (v) =>
                                      v == null ? 'نوع العقار مطلوب' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const FormFieldLabel('نوع النشاط'),
                                AppDropdownField(
                                  key: ValueKey(_type),
                                  value: _activity,
                                  hint: 'مقهى، مطعم،...',
                                  items: _activityOptions,
                                  onChanged: _type == null
                                      ? null
                                      : (v) => setState(() => _activity = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // 5) الحي
                      const FormFieldLabel('الحي', required: true),
                      AppTextField(
                        controller: _district,
                        hint: 'مثال: العليا',
                        validator: (v) => _requiredText(v, 'الحي مطلوب'),
                      ),

                      // 6) الشارع
                      const FormFieldLabel('الشارع'),
                      AppTextField(
                        controller: _address,
                        hint: 'الشارع و اقرب معلم',
                      ),

                      // 7) الموقع على الخريطة
                      const SizedBox(height: 12),
                      DashedBox(
                        onTap: _pickLocation,
                        hasError: mapError,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _latLng == null
                                  ? Icons.map_outlined
                                  : Icons.check_circle,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _latLng == null
                                  ? 'حدّد موقع العقار على الخريطة'
                                  : 'تم تحديد الموقع — اضغط للتغيير',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted),
                            ),
                            const Text('*',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.danger)),
                          ],
                        ),
                      ),
                      if (mapError)
                        const FieldErrorText('الموقع على الخريطة مطلوب'),

                      // 8) الإيجار + سعر مقترح
                      const FormFieldLabel('الإيجار السنوي (ر.س)',
                          required: true),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              hint: 'السعر المطلوب',
                              controller: _price,
                              focusNode: _priceFocus,
                              keyboardType: TextInputType.number,
                              inputFormatters: digits,
                              validator: (v) =>
                                  _requiredNumber(v, 'الإيجار مطلوب'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _suggestPrice,
                            borderRadius: BorderRadius.circular(kFieldRadius),
                            child: Container(
                              height: 56,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.beigeSoft,
                                borderRadius:
                                    BorderRadius.circular(kFieldRadius),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.auto_awesome,
                                      size: 14, color: AppColors.primary),
                                  SizedBox(width: 4),
                                  Text('سعر مقترح',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 9) الوصف
                      const FormFieldLabel('الوصف'),
                      AppTextField(
                        controller: _description,
                        hint: 'الواجهه، الحالة',
                        maxLines: 2,
                      ),

                      // 10) المواقف
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(kFieldRadius),
                          border:
                              Border.all(color: AppColors.border, width: 1.5),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Row(
                            children: [
                              Text('يوجد مواقف',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textDark)),
                            ],
                          ),
                          value: _hasParking,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _hasParking = v),
                        ),
                      ),

                      // 11) الصور
                      const SizedBox(height: 14),
                      ImagePickerSection(
                        images: _images,
                        mainIndex: _mainImage,
                        onImagesChanged: (v) => setState(() => _images = v),
                        onMainChanged: (v) => setState(() => _mainImage = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 12) زر النشر
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: CustomButton(
                text: _saving
                    ? 'جاري الحفظ...'
                    : (_isEdit ? 'حفظ التعديلات' : 'نشر العقار'),
                onPressed: _saving ? null : _submit,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(
        current: AppTab.myProperties,
      ),
    );
  }
}