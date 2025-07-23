import 'package:flutter/material.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/data/member_repository.dart';
import 'package:donation/utils/Colors.dart';
import 'package:intl/intl.dart';
import 'package:donation/responsive.dart';

class MemberEditScreen extends StatefulWidget {
  final String memberId;
  final Member member;

  const MemberEditScreen(
      {Key? key, required this.memberId, required this.member})
      : super(key: key);

  @override
  State<MemberEditScreen> createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends State<MemberEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final MemberRepository _repository = MemberRepository();

  late TextEditingController nameController;
  late TextEditingController fatherNameController;
  late TextEditingController birthDateController;
  late TextEditingController nrcController;
  late TextEditingController phoneController;
  late TextEditingController bloodBankController;
  late TextEditingController addressController;
  String? selectedBloodType;
  String? selectedGender;

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> bloodTypes = [
    'A (Rh +)',
    'B (Rh +)',
    'AB (Rh +)',
    'O (Rh +)',
    'A (Rh -)',
    'B (Rh -)',
    'AB (Rh -)',
    'O (Rh -)',
  ];

  final List<String> genders = ['male', 'female'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with member data
    nameController = TextEditingController(text: widget.member.name ?? '');
    fatherNameController =
        TextEditingController(text: widget.member.fatherName ?? '');
    birthDateController =
        TextEditingController(text: widget.member.birthDate ?? '');
    nrcController = TextEditingController(text: widget.member.nrc ?? '');
    phoneController = TextEditingController(text: widget.member.phone ?? '');
    bloodBankController =
        TextEditingController(text: widget.member.bloodBankCard ?? '');
    addressController =
        TextEditingController(text: widget.member.address ?? '');
    selectedBloodType = widget.member.bloodType;
    selectedGender = widget.member.gender;
  }

  @override
  void dispose() {
    nameController.dispose();
    fatherNameController.dispose();
    birthDateController.dispose();
    nrcController.dispose();
    phoneController.dispose();
    bloodBankController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _updateMember() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create updated member object
      final updatedMember = Member(
        id: widget.member.id,
        memberId: widget.member.memberId,
        name: nameController.text,
        fatherName: fatherNameController.text,
        birthDate: birthDateController.text,
        nrc: nrcController.text,
        phone: phoneController.text,
        bloodBankCard: bloodBankController.text,
        address: addressController.text,
        bloodType: selectedBloodType,
        gender: selectedGender,
        // Keep other fields unchanged
        memberCount: widget.member.memberCount,
        totalCount: widget.member.totalCount,
        registerDate: widget.member.registerDate,
        status: widget.member.status,
        lastDate: widget.member.lastDate,
        note: widget.member.note,
      );

      // Call update API
      await _repository.updateMember(widget.memberId, updatedMember);

      if (mounted) {
        // Return success result to parent screen
        Navigator.pop(context, {
          'success': true,
          'message': 'အဖွဲ့ဝင်အချက်အလက် အောင်မြင်စွာ ပြင်ဆင်ပြီးပါပြီ'
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });

        // Show error in dialog instead of SnackBar
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Error: $_errorMessage'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        // Format date as 'dd MMM yyyy'
        birthDateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return Scaffold(
      appBar: isMobile
          ? null
          : AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [primaryColor, primaryDark],
                  ),
                ),
              ),
              centerTitle: true,
              title: Text(
                "အချက်အလက် ပြင်ဆင်ရန်",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Center(
                child: Container(
                  width: isMobile ? double.infinity : MediaQuery.of(context).size.width * 0.5,
                  child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display member ID (non-editable)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "အဖွဲ့ဝင်အမှတ်",
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.member.memberId ?? 'N/A',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isMobile ? 16 : 20),

                      // Name
                      TextFormField(
                        controller: nameController,
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                        decoration: InputDecoration(
                          labelText: "အမည်",
                          labelStyle: TextStyle(fontSize: isMobile ? 13 : 15),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'အမည်ဖြည့်ရန် လိုအပ်ပါသည်';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // Father's Name
                      TextFormField(
                        controller: fatherNameController,
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                        decoration: InputDecoration(
                          labelText: "အဖအမည်",
                          labelStyle: TextStyle(fontSize: isMobile ? 13 : 15),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // Birth Date
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: birthDateController,
                            style: TextStyle(fontSize: isMobile ? 14 : 16),
                            decoration: InputDecoration(
                              labelText: "မွေးသက္ကရာဇ်",
                              labelStyle: TextStyle(fontSize: isMobile ? 13 : 15),
                              border: const OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 16,
                                vertical: isMobile ? 10 : 12,
                              ),
                              suffixIcon: Icon(Icons.calendar_today,
                                  color: primaryColor, size: isMobile ? 20 : 24),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // NRC
                      TextFormField(
                        controller: nrcController,
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                        decoration: InputDecoration(
                          labelText: "နိုင်ငံသားစီစစ်ရေး အမှတ်",
                          labelStyle: TextStyle(fontSize: isMobile ? 13 : 15),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // Phone
                      TextFormField(
                        controller: phoneController,
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                        decoration: InputDecoration(
                          labelText: "ဖုန်းနံပါတ်",
                          labelStyle: TextStyle(fontSize: isMobile ? 13 : 15),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // Blood Bank Card
                      TextFormField(
                        controller: bloodBankController,
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                        decoration: InputDecoration(
                          labelText: "သွေးဘဏ်ကတ်နံပါတ်",
                          labelStyle: TextStyle(fontSize: isMobile ? 13 : 15),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // Blood Type Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedBloodType,
                        style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "သွေးအုပ်စု",
                          labelStyle: TextStyle(fontSize: isMobile ? 13 : 15),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        items: bloodTypes.map((String bloodType) {
                          return DropdownMenuItem<String>(
                            value: bloodType,
                            child: Text(bloodType, style: TextStyle(fontSize: isMobile ? 14 : 16)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBloodType = newValue;
                          });
                        },
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // Gender Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "လိင်အမျိုးအစား",
                          labelStyle: TextStyle(fontSize: isMobile ? 13 : 15),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        items: genders.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender == 'male' ? 'ကျား' : 'မ', style: TextStyle(fontSize: isMobile ? 14 : 16)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue;
                          });
                        },
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // Address
                      TextFormField(
                        controller: addressController,
                        maxLines: 3,
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                        decoration: InputDecoration(
                          labelText: "နေရပ်လိပ်စာ",
                          labelStyle: TextStyle(fontSize: isMobile ? 13 : 15),
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 20 : 24),

                      // Error message
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isMobile ? 10 : 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade900, fontSize: isMobile ? 13 : 15),
                          ),
                        ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: isMobile ? 44 : 50,
                        child: ElevatedButton(
                          onPressed: _updateMember,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          child: Text(
                            "သိမ်းဆည်းမည်",
                            style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.white),
                          ),
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
