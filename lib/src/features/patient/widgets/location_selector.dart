import 'package:donation/data/township_detail/township_detail.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';

/// The structured result of the location selector.
class LocationValue {
  final String township;
  final String placeName; // ward or village name
  final String? placeType; // 'ward' | 'village' | null
  final String? group; // town (ward) or village-tract (village)

  const LocationValue({
    this.township = '',
    this.placeName = '',
    this.placeType,
    this.group,
  });

  String get ward => placeType == 'ward' ? placeName : '';
  String get village => placeType == 'village' ? placeName : '';

  /// Flat, human-readable address kept backward-compatible with the existing
  /// `address` column. Order: ward/village ၊ township.
  String get combinedAddress {
    final parts = [placeName.trim(), township.trim()]
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.join('၊');
  }

  bool get isEmpty =>
      township.trim().isEmpty && placeName.trim().isEmpty;
}

/// Cascading Township -> Quarter(ward)/Village selector.
///
/// Each field opens a searchable modal bottom sheet (rather than an inline
/// typeahead overlay) so selection is reliable and the parent form scrolls
/// freely.
class LocationSelector extends StatefulWidget {
  final LocationValue initial;
  final ValueChanged<LocationValue> onChanged;

  const LocationSelector({
    super.key,
    this.initial = const LocationValue(),
    required this.onChanged,
  });

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final _repo = TownshipDetailRepository.instance;

  late String _township;
  late String _placeName;
  String? _placeType;
  String? _group;

  @override
  void initState() {
    super.initState();
    _township = widget.initial.township;
    _placeName = widget.initial.placeName;
    _placeType = widget.initial.placeType;
    _group = widget.initial.group;

    _repo.ensureLoaded().then((_) {
      if (!mounted) return;
      if (_placeType == null &&
          _placeName.trim().isNotEmpty &&
          _township.trim().isNotEmpty) {
        final p = _repo.findPlace(_township.trim(), _placeName.trim());
        if (p != null) {
          _placeType = p.type;
          _group = p.group;
        }
      }
      setState(() {});
    });
  }

  void _emit() {
    widget.onChanged(LocationValue(
      township: _township.trim(),
      placeName: _placeName.trim(),
      placeType: _placeType,
      group: _group,
    ));
  }

  Future<void> _pickTownship() async {
    await _repo.ensureLoaded();
    if (!mounted) return;
    final selected = await _showSearchSheet<String>(
      title: 'မြို့နယ် ရွေးပါ',
      items: _repo.townshipNames,
      labelFor: (t) => t,
      subtitleFor: (t) {
        final d = _repo.township(t);
        return d == null ? null : '${d.district} • ${d.state}';
      },
    );
    if (selected != null) {
      setState(() {
        _township = selected;
        // Township changed -> reset dependent place selection.
        _placeName = '';
        _placeType = null;
        _group = null;
      });
      _emit();
    }
  }

  Future<void> _pickPlace() async {
    if (_township.trim().isEmpty) return;
    await _repo.ensureLoaded();
    if (!mounted) return;
    final places = _repo.placesFor(_township.trim());
    final selected = await _showSearchSheet<PlaceEntry>(
      title: 'ရပ်ကွက် / ကျေးရွာ ရွေးပါ',
      items: places,
      labelFor: (p) => p.name,
      subtitleFor: (p) => '${p.typeLabelMm} • ${p.group}',
    );
    if (selected != null) {
      setState(() {
        _placeName = selected.name;
        _placeType = selected.type;
        _group = selected.group;
      });
      _emit();
    }
  }

  Future<T?> _showSearchSheet<T>({
    required String title,
    required List<T> items,
    required String Function(T) labelFor,
    String? Function(T)? subtitleFor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final q = query.trim().toLowerCase();
            final filtered = q.isEmpty
                ? items
                : items
                    .where((e) => labelFor(e).toLowerCase().contains(q))
                    .toList();
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.75,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(title,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'ရှာဖွေရန်...',
                          prefixIcon: const Icon(Icons.search),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (v) => setSheetState(() => query = v),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text('မတွေ့ပါ',
                                  style: TextStyle(color: Colors.grey[600])))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final item = filtered[i];
                                final sub = subtitleFor?.call(item);
                                return ListTile(
                                  dense: true,
                                  title: Text(labelFor(item)),
                                  subtitle: sub == null
                                      ? null
                                      : Text(sub,
                                          style: const TextStyle(fontSize: 11)),
                                  onTap: () => Navigator.pop(ctx, item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _fieldBox({
    required String label,
    required String value,
    required String hint,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    final hasValue = value.trim().isNotEmpty;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
          filled: true,
          fillColor: enabled ? const Color(0xFFefefef) : const Color(0xFFf3f3f3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: Icon(Icons.keyboard_arrow_down,
              color: enabled ? Colors.grey[700] : Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(),
          ),
        ),
        child: Text(
          hasValue ? value : hint,
          style: TextStyle(
            fontSize: 15,
            color: hasValue ? Colors.black : Colors.grey[500],
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = _township.trim().isEmpty ? null : _repo.township(_township.trim());
    final combined = LocationValue(
      township: _township,
      placeName: _placeName,
    ).combinedAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldBox(
          label: 'မြို့နယ်',
          value: _township,
          hint: 'မြို့နယ် ရွေးပါ',
          onTap: _pickTownship,
          enabled: true,
        ),
        const SizedBox(height: 12),
        _fieldBox(
          label: 'ရပ်ကွက် / ကျေးရွာ',
          value: _placeName,
          hint: _township.trim().isEmpty
              ? 'မြို့နယ် အရင်ရွေးပါ'
              : 'ရပ်ကွက် / ကျေးရွာ ရွေးပါ',
          onTap: _pickPlace,
          enabled: _township.trim().isNotEmpty,
        ),
        if (combined.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 14, color: primaryColor),
                    const SizedBox(width: 4),
                    Text('လိပ်စာ',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 4),
                Text(combined,
                    style: const TextStyle(fontSize: 14, color: Colors.black87)),
                if (_placeType != null && _group != null && _group!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _placeType == 'ward'
                          ? 'မြို့: ${_group!}'
                          : 'ကျေးရွာအုပ်စု: ${_group!}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                if (detail != null)
                  Text('${detail.district} • ${detail.state}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
      ],
    );
  }
}
