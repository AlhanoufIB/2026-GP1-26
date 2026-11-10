import 'package:flutter/material.dart';

import '../../models/property.dart';
import '../../repositories/property_repository.dart';
import '../../repositories/saved_properties_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';
import 'property_details_screen.dart';
import 'utils/discovery_formatters.dart';
import 'widgets/property_image.dart';
import 'compare_properties_screen.dart';

/// "العقارات المحفوظة" — saved list + pick 2 to 4 properties to compare.
class SavedPropertiesScreen extends StatefulWidget {
  const SavedPropertiesScreen({super.key});

  @override
  State<SavedPropertiesScreen> createState() => _SavedPropertiesScreenState();
}

class _SavedPropertiesScreenState extends State<SavedPropertiesScreen> {
  static const int maxCompare = 4;

  final _saved = SavedPropertiesRepository.instance;
  late Future<List<Property>> _future;
  final Set<String> _selected = {}; // ids ticked for comparison

  @override
  void initState() {
    super.initState();
    _load();
    _saved.addListener(_load); // reload whenever something is (un)saved
  }

  @override
  void dispose() {
    _saved.removeListener(_load); // stop listening when the page closes
    super.dispose();
  }

  void _load() {
    setState(() {
      // forget ticks on properties that are no longer saved
      _selected.removeWhere((id) => !_saved.isSaved(id));
      _future = PropertyRepository.instance.getPropertiesByIds(_saved.savedIds);
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else if (_selected.length < maxCompare) {
        _selected.add(id);
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('يمكنك مقارنة 4 عقارات كحد أقصى')),
          );
      }
    });
  }

  void _openCompare() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ComparePropertiesScreen(propertyIds: _selected.toList()),
      ),
    );
  }

  String get _compareLabel {
    if (_selected.length < 2) return 'اختر عقارين للمقارنة';
    if (_selected.length == 2) return 'مقارنة العقارين المحددين';
    return 'مقارنة العقارات المحددة (${_selected.length})';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Property>>(
          future: _future,
          builder: (context, snapshot) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                ..._buildList(snapshot),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: PrimaryButton(
            text: _compareLabel,
            onPressed: _selected.length >= 2 ? _openCompare : null,
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
          'العقارات المحفوظة',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.brownDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'اختر عقارين أو أكثر للمقارنة بينها.',
          style: TextStyle(fontSize: 14, color: AppColors.hint),
        ),
      ],
    );
  }

  List<Widget> _buildList(AsyncSnapshot<List<Property>> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 48),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.brown),
          ),
        ),
      ];
    }

    final properties = snapshot.data ?? const [];
    if (properties.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 48),
          child: Column(
            children: [
              Icon(Icons.bookmark_border, size: 48, color: AppColors.hint),
              SizedBox(height: 12),
              Text(
                'لا توجد عقارات محفوظة بعد.\nاضغط "حفظ" في صفحة أي عقار لإضافته هنا.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.hint),
              ),
            ],
          ),
        ),
      ];
    }

    return [
      for (final p in properties)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _SavedRow(
            property: p,
            selected: _selected.contains(p.propertyId),
            onSelect: () => _toggleSelected(p.propertyId),
            onUnsave: () => _saved.toggle(p.propertyId),
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PropertyDetailsScreen(property: p),
              ),
            ),
          ),
        ),
    ];
  }
}

/// One saved property: checkbox, photo, text, filled bookmark (to unsave).
class _SavedRow extends StatelessWidget {
  final Property property;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onUnsave;
  final VoidCallback onOpen;

  const _SavedRow({
    required this.property,
    required this.selected,
    required this.onSelect,
    required this.onUnsave,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (_) => onSelect(),
                activeColor: AppColors.brown,
                side: const BorderSide(color: AppColors.brown, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: PropertyImage(path: property.coverImage),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brownDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatArea(property.areaSqm)} · ${formatYearlyRent(property.rentPrice)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.hint,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'إزالة من المحفوظات',
                onPressed: onUnsave,
                icon: const Icon(Icons.bookmark, color: AppColors.brown),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
