import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/age_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Age entry that captures years / months / days and converts it to a birth
/// date. The birth date is the source of truth and is surfaced via [onChanged]
/// so the caller can persist it (and recompute the age accurately later).
///
/// An exact birth date can also be picked directly; the year/month/day fields
/// are then back-filled from it.
class AgeInput extends StatefulWidget {
  final DateTime? initialBirthDate;
  final ValueChanged<DateTime?> onChanged;

  const AgeInput({
    super.key,
    this.initialBirthDate,
    required this.onChanged,
  });

  @override
  State<AgeInput> createState() => _AgeInputState();
}

class _AgeInputState extends State<AgeInput> {
  final _yearsController = TextEditingController();
  final _monthsController = TextEditingController();
  final _daysController = TextEditingController();
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialBirthDate != null) {
      _setFromBirthDate(widget.initialBirthDate!, notify: false);
    }
  }

  @override
  void dispose() {
    _yearsController.dispose();
    _monthsController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  int _parse(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  bool get _allEmpty =>
      _yearsController.text.trim().isEmpty &&
      _monthsController.text.trim().isEmpty &&
      _daysController.text.trim().isEmpty;

  void _recomputeFromParts() {
    setState(() {
      if (_allEmpty) {
        _birthDate = null;
      } else {
        _birthDate = birthDateFromAge(
          years: _parse(_yearsController),
          months: _parse(_monthsController),
          days: _parse(_daysController),
        );
      }
    });
    widget.onChanged(_birthDate);
  }

  void _setFromBirthDate(DateTime date, {bool notify = true}) {
    final age = ageFromBirthDate(date);
    _yearsController.text = age.years > 0 ? age.years.toString() : '';
    _monthsController.text = age.months > 0 ? age.months.toString() : '';
    _daysController.text = age.days > 0 ? age.days.toString() : '';
    _birthDate = DateTime(date.year, date.month, date.day);
    if (mounted) setState(() {});
    if (notify) widget.onChanged(_birthDate);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: 'မွေးသက္ကရာဇ် ရွေးချယ်ပါ',
    );
    if (picked != null) {
      _setFromBirthDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 3, child: _numberField(_yearsController, 'အသက် (နှစ်)')),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _numberField(_monthsController, 'လ')),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _numberField(_daysController, 'ရက်')),
            IconButton(
              tooltip: 'မွေးသက္ကရာဇ် ရွေးရန်',
              icon: Icon(Icons.calendar_month, color: primaryColor),
              onPressed: _pickDate,
            ),
          ],
        ),
        if (_birthDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'မွေးသက္ကရာဇ်: ${formatBirthDate(_birthDate!)}  •  ${formatAgeMm(ageFromBirthDate(_birthDate!))}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
      ],
    );
  }

  Widget _numberField(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [
        // Myanmar keyboards type ၀-၉; convert instead of silently rejecting,
        // otherwise the field cannot be typed into at all.
        const _MyanmarDigitsFormatter(),
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.black),
        fillColor: const Color(0xFFefefef),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(),
        ),
      ),
      onChanged: (_) => _recomputeFromParts(),
    );
  }
}

/// Maps Myanmar digits to ASCII as they are typed. The mapping is 1:1 per
/// UTF-16 code unit, so the selection and composing ranges stay valid.
class _MyanmarDigitsFormatter extends TextInputFormatter {
  const _MyanmarDigitsFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final normalized = normalizeMyanmarDigits(newValue.text);
    if (normalized == newValue.text) return newValue;
    return newValue.copyWith(text: normalized);
  }
}
