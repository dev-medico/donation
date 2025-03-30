import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/utils/Colors.dart';

class MemberEditScreen extends ConsumerStatefulWidget {
  final String memberId;

  const MemberEditScreen({Key? key, required this.memberId}) : super(key: key);

  @override
  ConsumerState<MemberEditScreen> createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends ConsumerState<MemberEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController fatherNameController;
  late TextEditingController birthDateController;
  late TextEditingController nrcController;
  late TextEditingController phoneController;
  late TextEditingController bloodBankController;
  late TextEditingController addressController;
  String? selectedBloodType;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    fatherNameController = TextEditingController();
    birthDateController = TextEditingController();
    nrcController = TextEditingController();
    phoneController = TextEditingController();
    bloodBankController = TextEditingController();
    addressController = TextEditingController();

    // Load member data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMemberData();
    });
  }

  void _loadMemberData() async {
    try {
      // Use the provider directly
      final memberAsync = ref.watch(memberByIdProvider(widget.memberId));

      memberAsync.when(data: (member) {
        setState(() {
          nameController.text = member.name ?? '';
          fatherNameController.text = member.fatherName ?? '';
          birthDateController.text = member.birthDate ?? '';
          nrcController.text = member.nrc ?? '';
          phoneController.text = member.phone ?? '';
          bloodBankController.text = member.bloodBankCard ?? '';
          addressController.text = member.address ?? '';
          selectedBloodType = member.bloodType;
          selectedGender = member.gender;
        });
      }, loading: () {
        // Handle loading state if needed
      }, error: (error, stackTrace) {
        // Handle error state if needed
        print('Error loading member: $error');
      });
    } catch (e) {
      print('Error in _loadMemberData: $e');
    }
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
        centerTitle: true,
        title: const Text(
          "အချက်အလက် ပြင်ဆင်ရန်",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("အဖွဲ့၀င် အချက်အလက်များ ပြင်ဆင်နေဆဲ ဖြစ်ပါသည်။"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("နောက်သို့"),
            ),
          ],
        ),
      ),
    );
  }
}
