import 'package:flutter/material.dart';
import '../../models/property_myProperty.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/app_bottom_nav.dart';

class PriceChoice {
  /// null = المستخدم اختار يدخل السعر بنفسه
  final int? price;
  const PriceChoice.use(this.price);
  const PriceChoice.manual() : price = null;
}

class SuggestedPriceScreen extends StatelessWidget {
  final String type;
  final int area;
  final String location;

  const SuggestedPriceScreen({
    super.key,
    required this.type,
    required this.area,
    required this.location,
  });

  // تقدير مؤقت (mock). لاحقاً يُستبدل بنتيجة نموذج الذكاء الاصطناعي من الـ API
  int get _suggested => ((area * 894) / 500).round() * 500;
  int get _min => ((_suggested * 0.92) / 1000).round() * 1000;
  int get _max => ((_suggested * 1.09) / 1000).round() * 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('العودة للعقار',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward,
                        size: 14, color: AppColors.textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'السعر الإيجاري المقترح',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _PriceCard(
                        price: _suggested,
                        min: _min,
                        max: _max,
                      ),
                      const SizedBox(height: 16),
                      _InfoCard(type: type, area: area, location: location),
                      const SizedBox(height: 12),
                      const Text(
                        'هذا السعر اقتراح مبني على بيانات السوق، والقرار النهائي لك.',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              CustomButton(
                text: 'استخدام هذا السعر',
                onPressed: () =>
                    Navigator.pop(context, PriceChoice.use(_suggested)),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'سأدخل السعر بنفسي',
                type: CustomButtonType.outlined,
                onPressed: () =>
                    Navigator.pop(context, const PriceChoice.manual()),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(
  current: AppTab.myProperties,
),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final int price;
  final int min;
  final int max;
  const _PriceCard(
      {required this.price, required this.min, required this.max});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('الإيجار السنوي المقدّر',
              style: TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            '${formatNumber(price)} ر.س',
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'النطاق المعتاد: ${formatNumber(min)} – ${formatNumber(max)} ر.س',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String type;
  final int area;
  final String location;
  const _InfoCard(
      {required this.type, required this.area, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('على ماذا يعتمد التقدير؟',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          _row('مساحة العقار ونوعه', '$type · $area م²'),
          _row('الموقع', location.isEmpty ? '—' : location),
          _row('أسعار الإيجار القريبة', 'بيانات السوق', last: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textDark)),
          const Spacer(),
          Flexible(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}