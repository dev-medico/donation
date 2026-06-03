import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/src/features/patient/providers/patient_provider.dart';
import 'package:donation/src/features/patient/widgets/age_input.dart';
import 'package:donation/src/features/patient/widgets/location_selector.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/age_utils.dart';
import 'package:donation/utils/tool_widgets.dart';
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
  final _medicalNotesController = TextEditingController();
  String? _selectedGender;
  String? _selectedBloodType;
  bool _isLoading = false;

  // Structured location (township + ward/village) and birth date.
  LocationValue _location = const LocationValue();
  DateTime? _birthDate;

  static const List<String> bloodTypes = [
    "A (Rh +)",
    "B (Rh +)",
    "AB (Rh +)",
    "O (Rh +)",
    "A (Rh -)",
    "B (Rh -)",
    "AB (Rh -)",
    "O (Rh -)",
  ];

  static const TextStyle _sectionLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF616161),
  );

  bool get isEditing => widget.patient != null;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    if (p != null) {
      _nameController.text = p.name ?? '';
      _phoneController.text = p.phone ?? '';
      _medicalNotesController.text = p.medicalNotes ?? '';
      _selectedGender = p.gender;
      _selectedBloodType = p.bloodType;
      _location = _initialLocation(p);
      _birthDate = parseBirthDate(p.birthDate);
      // Older records have only a numeric `age` string -> approximate the birth
      // date from it so editing keeps the age and starts persisting a real date.
      if (_birthDate == null) {
        final years = int.tryParse((p.age ?? '').trim());
        if (years != null && years > 0) {
          _birthDate = birthDateFromAge(years: years);
        }
      }
    }
  }

  LocationValue _initialLocation(Patient p) {
    final township = (p.township ?? '').trim();
    final ward = (p.ward ?? '').trim();
    final village = (p.village ?? '').trim();

    // Parse the flat address into up to [street, place, township].
    String aStreet = '', aPlace = '', aTownship = '';
    final parts = (p.address ?? '')
        .split('၊')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.length >= 3) {
      aTownship = parts.last;
      aPlace = parts[parts.length - 2];
      aStreet = parts.sublist(0, parts.length - 2).join('၊');
    } else if (parts.length == 2) {
      aPlace = parts[0];
      aTownship = parts[1];
    } else if (parts.length == 1) {
      aTownship = parts[0];
    }

    // Prefer structured columns (post-migration) for township/place; the
    // house/street number is only carried in the flat address.
    if (township.isNotEmpty || ward.isNotEmpty || village.isNotEmpty) {
      final isWard = ward.isNotEmpty;
      return LocationValue(
        township: township.isNotEmpty ? township : aTownship,
        placeName: isWard ? ward : (village.isNotEmpty ? village : aPlace),
        placeType: isWard ? 'ward' : (village.isNotEmpty ? 'village' : null),
        street: aStreet,
      );
    }
    if (aTownship.isEmpty && aPlace.isEmpty && aStreet.isEmpty) {
      return const LocationValue();
    }
    return LocationValue(
      township: aTownship,
      placeName: aPlace,
      street: aStreet,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final years =
          _birthDate != null ? ageFromBirthDate(_birthDate!).years : null;

      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _location.combinedAddress,
        'township': _location.township,
        'ward': _location.ward,
        'village': _location.village,
        'age': years != null ? years.toString() : '',
        'birth_date': _birthDate != null ? formatBirthDate(_birthDate!) : null,
        'gender': _selectedGender,
        'blood_type': _selectedBloodType,
        if (isEditing) 'medical_notes': _medicalNotesController.text.trim(),
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
            content: Text(isEditing
                ? 'အောင်မြင်စွာ ပြင်ဆင်ပြီးပါပြီ'
                : 'အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ'),
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
    final isMobile = Responsive.isMobile(context);

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
      body: SafeArea(
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            child: _buildFormCard(),
          ),
          _buildSaveButton(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  child: _buildFormCard(),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSaveButton(),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, left: 4, right: 4, top: 8),
      decoration: shadowDecoration(Colors.white),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            Container(
              margin:
                  const EdgeInsets.only(left: 20, top: 24, bottom: 8, right: 20),
              child: TextFormField(
                controller: _nameController,
                decoration: inputBoxDecoration('အမည် *'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'အမည် ထည့်သွင်းပါ';
                  }
                  return null;
                },
              ),
            ),
            // Phone field
            Container(
              margin:
                  const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
              child: TextFormField(
                controller: _phoneController,
                decoration: inputBoxDecoration('ဖုန်းနံပါတ်'),
                keyboardType: TextInputType.phone,
              ),
            ),
            // Gender dropdown
            Container(
              width: double.infinity,
              margin:
                  const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'ကျား/မ',
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.only(
                      left: 20, right: 12, bottom: 4, top: 4),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('ကျား')),
                  DropdownMenuItem(value: 'female', child: Text('မ')),
                ],
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                },
              ),
            ),
            // Blood type dropdown
            Container(
              width: double.infinity,
              margin:
                  const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
              child: DropdownButtonFormField<String>(
                value: _selectedBloodType,
                decoration: InputDecoration(
                  labelText: 'သွေးအုပ်စု',
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.only(
                      left: 20, right: 12, bottom: 4, top: 4),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: bloodTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedBloodType = value);
                },
              ),
            ),
            // Age section (years / months / days -> birth date)
            Container(
              margin: const EdgeInsets.only(left: 20, top: 16, bottom: 4, right: 20),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('အသက်', style: _sectionLabelStyle),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, bottom: 8, right: 20),
              child: AgeInput(
                initialBirthDate: _birthDate,
                onChanged: (date) => _birthDate = date,
              ),
            ),
            // Address section (township -> quarter/village)
            Container(
              margin: const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text('လူနာလိပ်စာ', style: _sectionLabelStyle),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, bottom: 8, right: 20),
              child: LocationSelector(
                initial: _location,
                onChanged: (value) => _location = value,
              ),
            ),
            // Medical notes (only for editing mode)
            if (isEditing) ...[
              Container(
                margin: const EdgeInsets.only(
                    left: 20, top: 16, bottom: 8, right: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFefefef),
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                child: TextFormField(
                  controller: _medicalNotesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'ကျန်းမာရေးမှတ်တမ်း',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 8, top: 12, right: 15),
                    hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _isLoading ? null : _savePatient,
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    isEditing ? 'ပြင်ဆင်မည်' : 'သိမ်းဆည်းမည်',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
