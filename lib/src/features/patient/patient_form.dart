import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/src/features/patient/providers/patient_provider.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PatientFormScreen extends ConsumerStatefulWidget {
  final Patient? patient;
  final VoidCallback? onSaved;

  const PatientFormScreen({
    super.key,
    this.patient,
    this.onSaved,
  });

  @override
  ConsumerState<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends ConsumerState<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;

  bool get isEditing => widget.patient != null;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      _nameController.text = widget.patient!.name ?? '';
      _phoneController.text = widget.patient!.phone ?? '';
      _addressController.text = widget.patient!.address ?? '';
      _ageController.text = widget.patient!.age ?? '';
      _medicalNotesController.text = widget.patient!.medicalNotes ?? '';
      _selectedGender = widget.patient!.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'age': _ageController.text.trim(),
        'gender': _selectedGender,
        'medical_notes': _medicalNotesController.text.trim(),
      };

      final service = ref.read(patientServiceProvider);

      if (isEditing) {
        await service.updatePatient(widget.patient!.id!, data);
      } else {
        await service.createPatient(data);
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
          isEditing ? 'လူနာအချက်အလက် ပြင်ဆင်ရန်' : 'လူနာအသစ် ထည့်သွင်းရန်',
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
              onPressed: _savePatient,
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
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'ကျား/မ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wc),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('ကျား')),
                  DropdownMenuItem(value: 'female', child: Text('မ')),
                ],
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'အသက်',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
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
                controller: _medicalNotesController,
                decoration: const InputDecoration(
                  labelText: 'ကျန်းမာရေးမှတ်တမ်း',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_information),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _savePatient,
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
