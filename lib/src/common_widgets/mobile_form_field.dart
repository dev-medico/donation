import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mobile-optimized text form field
class MobileFormField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  
  const MobileFormField({
    Key? key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onTap: onTap,
          readOnly: readOnly,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          focusNode: focusNode,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Mobile dropdown field
class MobileDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  
  const MobileDropdownField({
    Key? key,
    required this.label,
    this.value,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.hintText,
    this.validator,
    this.prefixIcon,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 24,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }
}

/// Mobile date picker field
class MobileDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? hintText;
  final String? Function(DateTime?)? validator;
  final String Function(DateTime)? dateFormat;
  
  const MobileDateField({
    Key? key,
    required this.label,
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.hintText,
    this.validator,
    this.dateFormat,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MobileFormField(
      label: label,
      hintText: hintText ?? 'Select date',
      readOnly: true,
      controller: TextEditingController(
        text: value != null 
            ? (dateFormat?.call(value!) ?? 
               '${value!.day}/${value!.month}/${value!.year}')
            : '',
      ),
      prefixIcon: const Icon(Icons.calendar_today, size: 20),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(1900),
          lastDate: lastDate ?? DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        onChanged?.call(date);
      },
      validator: validator != null 
          ? (val) => validator!(value)
          : null,
    );
  }
}

/// Mobile switch field
class MobileSwitchField extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  
  const MobileSwitchField({
    Key? key,
    required this.label,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.activeColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor ?? Colors.red,
          ),
        ],
      ),
    );
  }
}

/// Mobile checkbox field
class MobileCheckboxField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Color? activeColor;
  
  const MobileCheckboxField({
    Key? key,
    required this.label,
    required this.value,
    this.onChanged,
    this.activeColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged?.call(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: activeColor ?? Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mobile search field
class MobileSearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool autofocus;
  
  const MobileSearchField({
    Key? key,
    this.hintText = 'Search...',
    required this.onChanged,
    this.onClear,
    this.controller,
    this.autofocus = false,
  }) : super(key: key);
  
  @override
  State<MobileSearchField> createState() => _MobileSearchFieldState();
}

class _MobileSearchFieldState extends State<MobileSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
  
  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
    widget.onChanged(_controller.text);
  }
  
  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade600),
                  onPressed: _clearSearch,
                  splashRadius: 20,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}