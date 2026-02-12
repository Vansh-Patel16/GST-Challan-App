import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/business_info.dart';
import '../providers/invoice_provider.dart';

class MyInfoTab extends StatefulWidget {
  const MyInfoTab({super.key});

  @override
  State<MyInfoTab> createState() => _MyInfoTabState();
}

class _MyInfoTabState extends State<MyInfoTab> {
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _company = TextEditingController();
  final _gst = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final prov = Provider.of<InvoiceProvider>(context);
      if (prov.businessInfo != null) {
        _name.text = prov.businessInfo!.name;
        _contact.text = prov.businessInfo!.contact;
        _company.text = prov.businessInfo!.companyName;
        _gst.text = prov.businessInfo!.gstNo;
        _email.text = prov.businessInfo!.email;
        _address.text = prov.businessInfo!.address;
      }
      _isInitialized = true;
    }
  }

  void _save() async {
    final info = BusinessInfo(
      name: _name.text,
      contact: _contact.text,
      companyName: _company.text,
      gstNo: _gst.text,
      email: _email.text,
      address: _address.text,
    );
    await Provider.of<InvoiceProvider>(context, listen: false).updateBusinessInfo(info);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Info updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTextField(_name, 'Your Name'),
          const SizedBox(height: 16),
          _buildTextField(_contact, 'Contact Number', keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildTextField(_company, 'Company Name'),
          const SizedBox(height: 16),
          _buildTextField(_gst, 'GST Number'),
          const SizedBox(height: 16),
          _buildTextField(_email, 'Email ID', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField(_address, 'Address', maxLines: 3),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('SAVE INFO'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _company.dispose();
    _gst.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }
}
