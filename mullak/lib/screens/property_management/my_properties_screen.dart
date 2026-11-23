import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/property_myProperty.dart';
import '../../services/property_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart'; // عدّلي المسار لو مختلف
import '../../widgets/custom_button.dart';
import '../../widgets/property_card.dart';
import 'delete_property_dialog.dart';
import 'property_form_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final _service = PropertyService.instance;
  late Future<List<PropertySummary>> _future = _service.listMyProperties();

  String? _bannerText;
  bool _bannerIsError = false;
  bool _deleting = false;

  void _reload() => setState(() => _future = _service.listMyProperties());

  void _showBanner(String text, {bool error = false}) {
    setState(() {
      _bannerText = text;
      _bannerIsError = error;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _bannerText == text) setState(() => _bannerText = null);
    });
  }

    Future<void> _addProperty() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PropertyFormScreen()),
    );
    if (!mounted) return;
    _reload();
    if (ok == true) _showBanner('تم إضافة العقار بنجاح');
  }

    Future<void> _editProperty(PropertySummary summary) async {
    Property? property;
    try {
      property = await _service.getProperty(summary.id);
    } catch (e, st) {
      debugPrint('OPEN ERROR: $e\n$st');
      _showBanner('تعذّر فتح العقار، حاول مرة ثانية', error: true);
      return;
    }
    if (property == null) {
      _showBanner('العقار غير موجود', error: true);
      return;
    }
    if (!mounted) return;

    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => PropertyFormScreen(property: property)),
    );
    if (!mounted) return;
    _reload();
    if (ok == true) _showBanner('تم حفظ التعديلات بنجاح');
  }

  Future<void> _deleteProperty(PropertySummary property) async {
    if (_deleting) return;
    final confirmed = await showDeletePropertyDialog(context);
    if (!confirmed) return;

    setState(() => _deleting = true);
    try {
      // الكرت ما يختفي إلا بعد نجاح الحذف في الداتابيس
      await _service.deleteProperty(property.id);
      if (!mounted) return;
      _reload(); // نعيد التحميل من السيرفر عشان الواجهة = الداتابيس
      _showBanner('تم حذف العقار بنجاح');
    } catch (e, st) {
      debugPrint('DELETE ERROR: $e\n$st');
      if (!mounted) return;
      _showBanner('تعذّر حذف العقار، حاول مرة ثانية', error: true);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'عقاراتي',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              if (_bannerText != null) _Banner(_bannerText!, _bannerIsError),
              Expanded(
                child: FutureBuilder<List<PropertySummary>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      debugPrint('LIST ERROR: ${snapshot.error}');
                      return Center(
                        child: TextButton(
                          onPressed: _reload,
                          child: const Text('تعذّر التحميل، اضغط للمحاولة'),
                        ),
                      );
                    }
                    final properties = snapshot.data!;
                    if (properties.isEmpty) {
                      return const Center(
                        child: Text('ما عندك عقارات بعد',
                            style: TextStyle(color: AppColors.textMuted)),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => _reload(),
                      child: ListView.separated(
                        itemCount: properties.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final p = properties[i];
                          return PropertyCard(
                            property: p,
                            onEdit: () => _editProperty(p),
                            onDelete: () => _deleteProperty(p),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              CustomButton(text: 'إضافة عقار +', onPressed: _addProperty),
              const SizedBox(height: 12),
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

/// بنر النجاح (أخضر ✓) أو الخطأ (أحمر ✕)
class _Banner extends StatelessWidget {
  final String text;
  final bool isError;
  const _Banner(this.text, this.isError);

  @override
  Widget build(BuildContext context) {
    final bg = isError ? AppColors.dangerSoft : AppColors.success;
    final fg = isError ? AppColors.danger : AppColors.successText;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.close : Icons.check, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: fg)),
          ),
        ],
      ),
    );
  }
}