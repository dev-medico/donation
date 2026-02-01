import 'dart:convert';

import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/src/features/patient/providers/patient_provider.dart';
import 'package:donation/data/response/township_response/datum.dart';
import 'package:donation/data/response/township_response/township_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
  final _quarterController = TextEditingController();
  final _townController = TextEditingController();
  final _ageController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  String? _selectedGender;
  String? _selectedBloodType;
  bool _isLoading = false;

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

  // Township data
  late TownshipResponse townshipResponse;
  List<String> townships = <String>[];
  List<Datum> datas = <Datum>[];

  bool get isEditing => widget.patient != null;

  // Formatted address preview
  String get formattedAddress =>
      "${_quarterController.text}${_quarterController.text.isNotEmpty ? '၊' : ''}${_townController.text}";

  @override
  void initState() {
    super.initState();
    _loadTownships();
    if (widget.patient != null) {
      _nameController.text = widget.patient!.name ?? '';
      _phoneController.text = widget.patient!.phone ?? '';
      _ageController.text = widget.patient!.age ?? '';
      _medicalNotesController.text = widget.patient!.medicalNotes ?? '';
      _selectedGender = widget.patient!.gender;
      _selectedBloodType = widget.patient!.bloodType;
      // Parse address into quarter and township
      _parseAndFillAddress(widget.patient!.address);
    }
    // Add listeners to update address preview
    _quarterController.addListener(_onAddressChanged);
    _townController.addListener(_onAddressChanged);
  }

  void _onAddressChanged() {
    setState(() {});
  }

  Future<void> _loadTownships() async {
    final String response =
        await rootBundle.loadString('assets/json/township.json');
    townshipResponse = TownshipResponse.fromJson(json.decode(response));

    // Sort townships with Mon State first, then Mawlamyine specifically at the top
    List<Datum> mawlamyineTownships = [];
    List<Datum> otherMonStateTownships = [];
    List<Datum> otherStateTownships = [];

    for (var element in townshipResponse.data!) {
      if (element.township == 'မော်လမြိုင်') {
        mawlamyineTownships.add(element);
      } else if (element.region == 'Mon State') {
        otherMonStateTownships.add(element);
      } else {
        otherStateTownships.add(element);
      }
    }

    datas.clear();
    datas.addAll(mawlamyineTownships);
    datas.addAll(otherMonStateTownships);
    datas.addAll(otherStateTownships);

    townships.clear();
    Set<String> addedTownships = {};
    for (var element in datas) {
      if (!addedTownships.contains(element.township!)) {
        townships.add(element.township!);
        addedTownships.add(element.township!);
      }
    }
    setState(() {});
  }

  void _parseAndFillAddress(String? address) {
    if (address == null || address.isEmpty) return;
    final parts = address.split('၊');
    if (parts.length >= 2) {
      _quarterController.text = parts[0].trim();
      _townController.text = parts[1].trim();
    } else {
      _townController.text = address;
    }
  }

  @override
  void dispose() {
    _quarterController.removeListener(_onAddressChanged);
    _townController.removeListener(_onAddressChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _quarterController.dispose();
    _townController.dispose();
    _ageController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Combine quarter and town into address
      final address = formattedAddress;

      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': address,
        'age': _ageController.text.trim(),
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
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            child: _buildFormCard(),
          ),
          _buildSaveButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
                const SizedBox(height: 20),
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
              margin: const EdgeInsets.only(left: 20, top: 24, bottom: 8, right: 20),
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
              margin: const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
              child: TextFormField(
                controller: _phoneController,
                decoration: inputBoxDecoration('ဖုန်းနံပါတ်'),
                keyboardType: TextInputType.phone,
              ),
            ),
            // Gender dropdown
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
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
                  contentPadding: const EdgeInsets.only(left: 20, right: 12, bottom: 4, top: 4),
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
              margin: const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
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
                  contentPadding: const EdgeInsets.only(left: 20, right: 12, bottom: 4, top: 4),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: bloodTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedBloodType = value);
                },
              ),
            ),
            // Age field
            Container(
              margin: const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
              child: TextFormField(
                controller: _ageController,
                decoration: inputBoxDecoration('အသက်'),
                keyboardType: TextInputType.number,
              ),
            ),
            // Address section label
            Container(
              margin: const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
              child: Text(
                'လူနာလိပ်စာ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
            // Quarter and Township in a row
            Container(
              margin: const EdgeInsets.only(left: 20, bottom: 8, right: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quarterController,
                      decoration: inputBoxDecoration('ရပ်ကွက်'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TypeAheadField<String>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _townController,
                        decoration: inputBoxDecoration('မြို့နယ်'),
                      ),
                      suggestionsCallback: (pattern) {
                        List<String> suggestions = [];

                        if (pattern.isEmpty) {
                          // When no pattern, ensure မော်လမြိုင် is first
                          if (townships.contains('မော်လမြိုင်')) {
                            suggestions.add('မော်လမြိုင်');
                            suggestions.addAll(townships.where((t) => t != 'မော်လမြိုင်').take(9));
                          } else {
                            suggestions = townships.take(10).toList();
                          }
                        } else {
                          // When filtering, still prioritize မော်လမြိုင် if it matches
                          final filteredTownships = townships
                              .where((township) => township
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                              .toList();

                          // If မော်လမြိုင် matches, put it first
                          if (filteredTownships.contains('မော်လမြိုင်')) {
                            suggestions.add('မော်လမြိုင်');
                            suggestions.addAll(filteredTownships.where((t) => t != 'မော်လမြိုင်').take(9));
                          } else {
                            suggestions = filteredTownships.take(10).toList();
                          }
                        }

                        return suggestions;
                      },
                      itemBuilder: (context, String township) {
                        return ListTile(
                          title: Text(township),
                        );
                      },
                      onSuggestionSelected: (String township) {
                        _townController.text = township;
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Address preview
            if (_quarterController.text.isNotEmpty || _townController.text.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 20, bottom: 8, right: 20),
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'လိပ်စာပြည့်စုံ:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            // Medical notes (only for editing mode)
            if (isEditing) ...[
              Container(
                margin: const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
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
                    contentPadding: EdgeInsets.only(left: 15, bottom: 8, top: 12, right: 15),
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
