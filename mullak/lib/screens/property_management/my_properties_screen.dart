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

  List<PropertySummary> _items = [];
  bool _loading = true;
  bool _loadFailed = false;
  bool _busy = false;
  String? _bannerText;
  bool _bannerIsError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _service.listMyProperties();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
        _loadFailed = false;
      });
    } catch (e, st) {
      debugPrint('LIST ERROR: $e\n$st');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

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
    await _load(); // القائمة محدثة قبل ما يشوفها المستخدم
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
      await _load();
      return;
    }
    if (!mounted) return;

    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => PropertyFormScreen(property: property)),
    );
    if (!mounted) return;
    await _load();
    if (ok == true) _showBanner('تم حفظ التعديلات بنجاح');
  }

  Future<void> _deleteProperty(PropertySummary property) async {
    if (_busy) return;
    final confirmed = await showDeletePropertyDialog(context);
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      await _service.deleteProperty(property.id); // يتأكد من الداتابيس
      if (!mounted) return;
      setState(() => _items.removeWhere((p) => p.id == property.id));
      _showBanner('تم حذف العقار بنجاح');
    } catch (e, st) {
      debugPrint('DELETE ERROR: $e\n$st');
      if (!mounted) return;
      _showBanner('تعذّر حذف العقار، حاول مرة ثانية', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_loadFailed) {
      return Center(
        child: TextButton(
          onPressed: () {
            setState(() => _loading = true);
            _load();
          },
          child: const Text('تعذّر التحميل، اضغط للمحاولة'),
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(
        child: Text('لا يوجد لديك عقارات بعد',
            style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final p = _items[i];
          return PropertyCard(
            property: p,
            onEdit: () => _editProperty(p),
            onDelete: () => _deleteProperty(p),
          );
        },
      ),
    );
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
              Expanded(child: _body()),
              CustomButton(text: 'إضافة عقار +', onPressed: _addProperty),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppTab.myProperties),
    );
  }
}

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
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
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