import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../../models/property_myProperty.dart';
import '../../services/property_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart'; // عدّلي المسار لو مختلف
import '../../widgets/back_link.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/image_picker_section.dart';
import 'location_picker_screen.dart';
import 'suggested_price_screen.dart';

class PropertyFormScreen extends StatefulWidget {
  /// null = إضافة عقار جديد، غير null = تعديل
  final Property? property;
  const PropertyFormScreen({super.key, this.property});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  late final TextEditingController _type;
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

  bool get _isEdit => widget.property != null;

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _type = TextEditingController(text: p?.propertyType ?? '');
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
    _type.dispose();
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

  Future<void> _suggestPrice() async {
    final area = int.tryParse(_area.text.trim());
    if (_type.text.trim().isEmpty || area == null || area <= 0) {
      _showMessage('أدخل نوع العقار والمساحة أولاً لنقترح لك سعراً');
      return;
    }

    final choice = await Navigator.push<PriceChoice>(
      context,
      MaterialPageRoute(
        builder: (_) => SuggestedPriceScreen(
          type: _type.text.trim(),
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
    final area = int.tryParse(_area.text.trim());
    final price = int.tryParse(_price.text.trim());
    final type = _type.text.trim();
    final district = _district.text.trim();

    if (type.isEmpty || area == null || district.isEmpty || price == null) {
      _showMessage('عبّي نوع العقار والمساحة والحي والإيجار السنوي');
      return;
    }
    if (_latLng == null) {
      _showMessage('حدّد موقع العقار على الخريطة');
      return;
    }

    setState(() => _saving = true);
    try {
      final old = widget.property;
      final property = Property(
        id: old?.id ?? '',
        title: Property.buildTitle(type, district), // تلقائي
        propertyType: type,
        areaSqm: area.toDouble(),
        district: district,
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
    }
    finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.digitsOnly];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                    if (_isEdit) ...[
                      const SizedBox(height: 4),
                      Text('رقم العقار \u2066${widget.property!.shortId}\u2069',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'نوع العقار',
                            hint: 'محل، مكتب، أرض',
                            controller: _type,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'المساحة (م²)',
                            hint: 'مثال: 85',
                            controller: _area,
                            keyboardType: TextInputType.number,
                            inputFormatters: digits,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'الحي',
                      hint: 'مثال: العليا',
                      controller: _district,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'العنوان',
                      hint: 'الشارع وأقرب معلم',
                      controller: _address,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickLocation,
                      child: Container(
                        width: double.infinity,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.beige,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const FieldLabel('الإيجار السنوي (ر.س)'),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            hint: 'السعر المطلوب',
                            controller: _price,
                            focusNode: _priceFocus,
                            keyboardType: TextInputType.number,
                            inputFormatters: digits,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _suggestPrice,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 48,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.beigeSoft,
                              borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'الوصف',
                      hint: 'الواجهة، المواقف، الحالة',
                      controller: _description,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('يوجد مواقف',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textDark)),
                        value: _hasParking,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _hasParking = v),
                      ),
                    ),
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