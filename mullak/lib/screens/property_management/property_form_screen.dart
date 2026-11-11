import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/property_myProperty.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'suggested_price_screen.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/image_picker_section.dart';
import 'location_picker_screen.dart';

class PropertyFormScreen extends StatefulWidget {
  /// null = إضافة عقار جديد، غير null = تعديل
  final property_myProperty? property;
  const PropertyFormScreen({super.key, this.property});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  late final TextEditingController _type;
  late final TextEditingController _area;
  late final TextEditingController _location;
  late final TextEditingController _price;
  late final TextEditingController _description;
  final _priceFocus = FocusNode();

  List<String> _images = [];
  int _mainImage = 0;
  LatLng? _latLng;

  bool get _isEdit => widget.property != null;

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _type = TextEditingController(text: p?.type ?? '');
    _area = TextEditingController(text: p?.area.toString() ?? '');
    _location = TextEditingController(text: p?.location ?? '');
    _price = TextEditingController(text: p?.annualRent.toString() ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _images = [...?p?.imagePaths];
    _mainImage = p?.mainImageIndex ?? 0;
    if (p?.lat != null && p?.lng != null) {
      _latLng = LatLng(p!.lat!, p.lng!);
    }
  }

  @override
  void dispose() {
    _type.dispose();
    _area.dispose();
    _location.dispose();
    _price.dispose();
    _description.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

    Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initial: _latLng),
      ),
    );
    if (result != null) setState(() => _latLng = result);
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
          location: _location.text.trim(),
        ),
      ),
    );

    if (choice == null) return; // رجع بدون اختيار: ما يتغير شي

    if (choice.price != null) {
      // استخدام السعر المقترح: يتعبأ الحقل تلقائياً
      setState(() => _price.text = choice.price.toString());
    } else {
      // سأدخل بنفسي: الحقل يفضى
      setState(() => _price.clear());
      _priceFocus.requestFocus();
    }
  }

  void _submit() {
    final area = int.tryParse(_area.text.trim());
    final price = int.tryParse(_price.text.trim());

    if (_type.text.trim().isEmpty ||
        area == null ||
        _location.text.trim().isEmpty ||
        price == null) {
      _showMessage('عبّي نوع العقار والمساحة والموقع والإيجار السنوي');
      return;
    }

    final property = property_myProperty(
      id: widget.property?.id ??
          (DateTime.now().millisecondsSinceEpoch % 100000),
      type: _type.text.trim(),
      area: area,
      location: _location.text.trim(),
      annualRent: price,
      description: _description.text.trim(),
      imagePaths: _images,
      mainImageIndex: _mainImage,
      lat: _latLng?.latitude,
      lng: _latLng?.longitude,
    );
    
     if (_latLng == null) {
      _showMessage('حدّد موقع العقار على الخريطة');
      return;
    }

    Navigator.pop(context, property);
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
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('عقاراتي',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward,
                              size: 14, color: AppColors.textMuted),
                        ],
                      ),
                    ),
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
                      Text('رقم العقار ${widget.property!.id}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                    const SizedBox(height: 18),

                    // نوع العقار + المساحة
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
                      label: 'الموقع',
                      hint: 'الحي والشارع',
                      controller: _location,
                    ),
                    const SizedBox(height: 12),

                    // مكان اختيار الموقع على الخريطة 
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

                    // الإيجار السنوي + زر السعر المقترح
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
                      hint: 'الواجهة، الموافق، الحالة',
                      controller: _description,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),

                    // إضافة صور 
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: CustomButton(
                text: _isEdit ? 'حفظ التعديلات' : 'نشر العقار',
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}