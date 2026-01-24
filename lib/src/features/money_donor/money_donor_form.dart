import 'package:donation/src/features/money_donor/models/money_donor.dart';
import 'package:donation/src/features/money_donor/providers/money_donor_provider.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
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
            // Organization toggle
            Container(
              margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 8),
              child: SwitchListTile(
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
            ),
            // Address field
            Container(
              margin: const EdgeInsets.only(left: 20, top: 8, bottom: 8, right: 20),
              child: TextFormField(
                controller: _addressController,
                decoration: inputBoxDecoration('လိပ်စာ'),
                maxLines: 2,
              ),
            ),
            // Note field
            Container(
              margin: const EdgeInsets.only(left: 20, top: 16, bottom: 8, right: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFefefef),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              child: TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'မှတ်ချက်',
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
        onTap: _isLoading ? null : _saveDonor,
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
