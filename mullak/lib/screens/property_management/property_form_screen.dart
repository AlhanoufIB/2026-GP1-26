import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../../models/property_myProperty.dart';
import '../../services/property_service.dart';
import '../../services/reverse_geocode_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/back_link.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/image_picker_section.dart';
import 'location_picker_screen.dart';
import 'suggested_price_screen.dart';
import '../map/heatmap_data.dart' show loadDatasetPoints;
import '../../data/riyadh_districts.dart'; // قائمة أحياء الرياض الثابتة

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
/// Districts covered by the rental data (Suhail dataset).
const kScopeDistricts = ['النرجس', 'قرطبة', 'ظهرة لبن'];

/// True if the typed district is one of the 3 (accepts "حي النرجس" too).
bool isScopeDistrict(String text) {
  final d = text.trim().replaceFirst(RegExp(r'^حي\s+'), '');
  return kScopeDistricts.contains(d);
}

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
  String? _district; // يُختار من قائمة أحياء الرياض الثابتة

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
  late final TextEditingController _address;
  late final TextEditingController _price;
  late final TextEditingController _description;
  final _titleFocus = FocusNode();
  final _areaFocus = FocusNode();
  final _districtFocus = FocusNode();
  final _priceFocus = FocusNode();

  List<String> _images = [];
  int _mainImage = 0;
  LatLng? _latLng;
  bool _hasParking = false;
  double? _estimated;
  bool _saving = false;
  final _locationFocus = FocusNode();
  List<String> _districts = []; // Riyadh districts from the heat map data
  bool _submitted = false;

  // ── الشارع يُعبّأ تلقائياً من موقع الدبوس (OpenStreetMap) ──
  bool _lookingUp = false; // جارٍ جلب اسم الشارع
  PinAddress? _pinAddress; // آخر نتيجة للدبوس الحالي
  bool _lookupFailed = false; // تعذّر الاتصال بالخدمة

  /// رسالة خطأ إذا كان الدبوس خارج الحي المختار، وإلا null
  String? get _locationError {
    if (_pinAddress == null || _district == null) return null;
    final inside = ReverseGeocodeService.isInDistrict(_pinAddress!, _district!);
    return inside == false
        ? 'الموقع المحدد خارج حي $_district، حدّد موقعاً داخل الحي'
        : null;
  }

  bool get _isEdit => widget.property != null;

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _type = (p?.propertyType.isEmpty ?? true) ? null : p!.propertyType;
    _activity = (p?.activityType?.isEmpty ?? true) ? null : p!.activityType;
    _district =
        (p?.district.trim().isEmpty ?? true) ? null : p!.district.trim();
    _title = TextEditingController(text: p?.title ?? '');
    _area = TextEditingController(text: p?.areaSqm.round().toString() ?? '');
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
    _address.dispose();
    _price.dispose();
    _description.dispose();
    _titleFocus.dispose();
    _areaFocus.dispose();
    _districtFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // ───────── التحقق الفوري (يظهر للمستخدم أثناء الكتابة، قبل الإرسال) ─────────
  String? _vTitle(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'العنوان مطلوب';
    if (t.length < 3) return 'العنوان قصير جداً (3 أحرف على الأقل)';
    if (t.length > 80) return 'العنوان طويل (الحد الأقصى 80 حرفاً)';
    return null;
  }

  String? _vArea(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'المساحة مطلوبة';
    final n = int.tryParse(t);
    if (n == null) return 'أدخل أرقاماً فقط';
    if (n <= 0) return 'المساحة يجب أن تكون أكبر من 0';
    return null;
  }

  // الحي لازم يكون مختار ومن قائمة أحياء الرياض المسموحة فقط
  String? _vDistrict(String? v) {
    if (v == null || v.trim().isEmpty) return 'الحي مطلوب';
    if (!kRiyadhDistricts.contains(v.trim())) return 'اختر الحي من القائمة';
    return null;
  }

  String? _vPrice(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'الإيجار مطلوب';
    final n = int.tryParse(t);
    if (n == null) return 'أدخل أرقاماً فقط';
    if (n <= 0) return 'الإيجار يجب أن يكون أكبر من 0';
    return null;
  }

  Future<void> _suggestPrice() async {
    final area = int.tryParse(_area.text.trim());
    if (_type == null || area == null || area <= 0) {
      _showMessage('أدخل نوع العقار والمساحة أولاً لنقترح لك سعراً');
      return;
    }

    final district = _district;
    if (district == null) {
      _showMessage('اختر الحي أولاً لنقترح لك سعراً');
      return;
    }
    if (!isScopeDistrict(district)) {
      _showMessage(
          'السعر المقترح متاح حالياً فقط لأحياء: ${kScopeDistricts.join('، ')}');
      return;
    }

    final choice = await Navigator.push<PriceChoice>(
      context,
      MaterialPageRoute(
        builder: (_) => SuggestedPriceScreen(
          type: _type!,
          area: area,
          district: _district ?? '',
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
    if (result == null) return;
    setState(() => _latLng = result);
    await _resolvePin(result);
  }

  /// يجلب اسم الشارع (والحي) للدبوس ويعبّئ حقل الشارع تلقائياً
  Future<void> _resolvePin(LatLng point) async {
    setState(() {
      _lookingUp = true;
      _lookupFailed = false;
    });
    final res = await ReverseGeocodeService.instance.lookup(point);
    if (!mounted || _latLng != point) return; // تغيّر الدبوس أثناء الانتظار
    setState(() {
      _lookingUp = false;
      _pinAddress = res;
      _lookupFailed = res == null;
      _address.text = res?.street ?? '';
    });
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    _formKey.currentState!.validate(); // يُظهر الأخطاء الحمراء تحت الحقول

    // نجمع الحقول الخاطئة ونوجّه المستخدم لأول واحد
    final problems = <String>[];
    FocusNode? firstFocus;
    void check(String label, bool bad, [FocusNode? f]) {
      if (!bad) return;
      problems.add(label);
      firstFocus ??= f;
    }

    check('العنوان', _vTitle(_title.text) != null, _titleFocus);
    check('المساحة', _vArea(_area.text) != null, _areaFocus);
    check('نوع العقار', _type == null);
    check('الحي', _vDistrict(_district) != null);
    check('الموقع على الخريطة', _latLng == null || _locationError != null);
    if (_lookingUp) {
      _showMessage('جارٍ التحقق من الموقع، انتظر لحظة');
      return;
    }
    check('الإيجار', _vPrice(_price.text) != null, _priceFocus);

    if (problems.isNotEmpty) {
      _showMessage('يرجى تصحيح: ${problems.join('، ')}');
      firstFocus?.requestFocus(); // يمرّر الشاشة للحقل الخاطئ تلقائياً
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
        district: _district!,
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        focusNode: _titleFocus,
                        validator: _vTitle,
                      ),

                      // 2) المساحة
                      const FormFieldLabel('المساحة (م²)', required: true),
                      AppTextField(
                        controller: _area,
                        hint: 'مثال: 85',
                        keyboardType: TextInputType.number,
                        inputFormatters: digits,
                        focusNode: _areaFocus,
                        validator: _vArea,
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

                      // 5) الحي (قائمة ثابتة لأحياء الرياض)
                      const FormFieldLabel('الحي', required: true),
                      AppSearchPickerField(
                        value: _district,
                        hint: 'اختر الحي',
                        sheetTitle: 'اختر الحي',
                        items: kRiyadhDistricts,
                        onChanged: (v) => setState(() => _district = v),
                        validator: _vDistrict,
                      ),

                      // 6) الشارع — يُعبّأ تلقائياً من الدبوس ولا يُكتب يدوياً،
                      //    حتى يطابق الموقع الفعلي دائماً
                      const FormFieldLabel('الشارع'),
                      TextFormField(
                        controller: _address,
                        readOnly: true,
                        enableInteractiveSelection: false,
                        onTap: _pickLocation,
                        decoration: appInputDecoration(
                          _lookingUp
                              ? 'جارٍ تحديد الشارع...'
                              : _latLng == null
                                  ? 'يُحدَّد تلقائياً بعد اختيار الموقع على الخريطة'
                                  : 'لم يُعثر على اسم شارع لهذا الموقع',
                        ),
                      ),
                      if (_lookupFailed)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'تعذّر جلب اسم الشارع، تأكد من الإنترنت ثم أعد تحديد الموقع',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textMuted),
                          ),
                        ),

                      // 7) الموقع على الخريطة
                      const SizedBox(height: 12),
                      DashedBox(
                        onTap: _pickLocation,
                        hasError: mapError || _locationError != null,
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
                      if (_locationError != null)
                        FieldErrorText(_locationError!),

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
                              validator: _vPrice,
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

                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'السعر المقترح متاح حالياً لأحياء: ${kScopeDistricts.join('، ')}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textMuted),
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
