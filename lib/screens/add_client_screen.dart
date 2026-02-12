import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/client.dart';
import '../providers/invoice_provider.dart';

class AddClientScreen extends StatefulWidget {
  final Client? client;
  const AddClientScreen({super.key, this.client});
  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}
class _AddClientScreenState extends State<AddClientScreen> {
  final _name = TextEditingController(),
      _gst = TextEditingController(),
      _addr = TextEditingController(),
      _phone = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _name.text = widget.client!.name;
      _gst.text = widget.client!.gstNo;
      _addr.text = widget.client!.address;
      _phone.text = widget.client!.phone;
    }
  }

  void _saveClient() async {
    if (_name.text.isEmpty || _gst.text.isEmpty || _addr.text.isEmpty || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final c = Client(
          id: widget.client?.id,
          name: _name.text,
          gstNo: _gst.text,
          address: _addr.text,
          phone: _phone.text);
      
      final prov = Provider.of<InvoiceProvider>(context, listen: false);
      if (widget.client == null) {
        await prov.addClient(c);
      } else {
        await prov.updateClient(c);
      }
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.client == null ? 'Add Client' : 'Edit Client')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Client Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _gst,
            decoration: const InputDecoration(
              labelText: 'GSTIN',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addr,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _saveClient,
              child: Text(_loading ? 'Saving...' : 'SAVE'),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _gst.dispose();
    _addr.dispose();
    _phone.dispose();
    super.dispose();
  }
}