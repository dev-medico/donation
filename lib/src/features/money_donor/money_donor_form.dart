import 'package:donation/src/features/money_donor/models/money_donor.dart';
import 'package:donation/src/features/money_donor/providers/money_donor_provider.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MoneyDonorFormScreen extends ConsumerStatefulWidget {
  final MoneyDonor? donor;
  final VoidCallback? onSaved;

  const MoneyDonorFormScreen({
    super.key,
    this.donor,
    this.onSaved,
  });

  @override
  ConsumerState<MoneyDonorFormScreen> createState() => _MoneyDonorFormScreenState();
}

class _MoneyDonorFormScreenState extends ConsumerState<MoneyDonorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isOrganization = false;
  bool _isLoading = false;

  bool get isEditing => widget.donor != null;

  @override
  void initState() {
    super.initState();
    if (widget.donor != null) {
      _nameController.text = widget.donor!.name ?? '';
      _phoneController.text = widget.donor!.phone ?? '';
      _addressController.text = widget.donor!.address ?? '';
      _noteController.text = widget.donor!.note ?? '';
      _isOrganization = widget.donor!.isOrganization ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveDonor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'note': _noteController.text.trim(),
        'is_organization': _isOrganization,
      };

      final service = ref.read(moneyDonorServiceProvider);

      if (isEditing) {
        await service.updateMoneyDonor(widget.donor!.id!, data);
      } else {
        await service.createMoneyDonor(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'အောင်မြင်စွာ ပြင်ဆင်ပြီးပါပြီ' : 'အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ'),
          ),
        );
        widget.onSaved?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('သိမ်းဆည်းရန် မအောင်မြင်ပါ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          isEditing ? 'အလှူရှင်အချက်အလက် ပြင်ဆင်ရန်' : 'အလှူရှင်အသစ် ထည့်သွင်းရန်',
          style: const TextStyle(fontSize: 17, color: Colors.white),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _saveDonor,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'အမည် *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'အမည် ထည့်သွင်းပါ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'ဖုန်းနံပါတ်',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('အဖွဲ့အစည်း'),
                subtitle: Text(
                  _isOrganization ? 'အဖွဲ့အစည်း/ကုမ္ပဏီ' : 'လူပုဂ္ဂိုလ်',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                value: _isOrganization,
                onChanged: (value) {
                  setState(() => _isOrganization = value);
                },
                activeColor: primaryColor,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'လိပ်စာ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'မှတ်ချက်',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveDonor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEditing ? 'ပြင်ဆင်မည်' : 'သိမ်းဆည်းမည်',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
