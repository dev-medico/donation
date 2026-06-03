import 'package:donation/src/features/monthly_sponsor/models/monthly_sponsor.dart';
import 'package:donation/src/features/monthly_sponsor/monthly_sponsor_service.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MonthlySponsorFormScreen extends ConsumerStatefulWidget {
  final MonthlySponsor? sponsor;
  final VoidCallback? onSaved;
  const MonthlySponsorFormScreen({super.key, this.sponsor, this.onSaved});

  @override
  ConsumerState<MonthlySponsorFormScreen> createState() =>
      _MonthlySponsorFormScreenState();
}

class _MonthlySponsorFormScreenState
    extends ConsumerState<MonthlySponsorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  bool get isEditing => widget.sponsor != null;

  @override
  void initState() {
    super.initState();
    final s = widget.sponsor;
    if (s != null) {
      _nameController.text = s.name ?? '';
      _phoneController.text = s.phone ?? '';
      _noteController.text = s.note ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'note': _noteController.text.trim(),
      };
      final service = ref.read(monthlySponsorServiceProvider);
      if (isEditing) {
        await service.updateSponsor(widget.sponsor!.id!, data);
      } else {
        await service.createSponsor(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isEditing
                ? 'အောင်မြင်စွာ ပြင်ဆင်ပြီးပါပြီ'
                : 'အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ')));
        widget.onSaved?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('မအောင်မြင်ပါ — $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [primaryColor, primaryDark],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isEditing ? 'ထောက်ပံ့သူ ပြင်ဆင်ရန်' : 'ထောက်ပံ့သူ အသစ်',
          style: const TextStyle(fontSize: 17, color: Colors.white),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                ),
              ),
            )
          else
            IconButton(
                icon: const Icon(Icons.save, color: Colors.white),
                onPressed: _save),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.only(bottom: 20, left: 4, right: 4, top: 8),
            decoration: shadowDecoration(Colors.white),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: inputBoxDecoration('အမည် *'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'အမည် ထည့်သွင်းပါ'
                          : null,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: inputBoxDecoration('ဖုန်းနံပါတ်'),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: TextFormField(
                      controller: _noteController,
                      decoration: inputBoxDecoration('မှတ်ချက်'),
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
