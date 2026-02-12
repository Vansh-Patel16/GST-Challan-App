import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/invoice_provider.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  const AddProductScreen({super.key, this.product});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}
class _AddProductScreenState extends State<AddProductScreen> {
  final _name = TextEditingController(),
      _rate = TextEditingController(),
      _gst = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _name.text = widget.product!.name;
      _rate.text = widget.product!.rate.toString();
      _gst.text = widget.product!.gstRate.toString();
    }
  }

  void _saveProduct() async {
    if (_name.text.isEmpty || _rate.text.isEmpty || _gst.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final p = Product(
          id: widget.product?.id,
          name: _name.text,
          rate: double.parse(_rate.text),
          gstRate: double.parse(_gst.text));
      
      final prov = Provider.of<InvoiceProvider>(context, listen: false);
      if (widget.product == null) {
        await prov.addProduct(p);
      } else {
        await prov.updateProduct(p);
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
      appBar: AppBar(title: Text(widget.product == null ? 'Add Product' : 'Edit Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Product Name (e.g., Cylinder, Drum)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _rate,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Rate (₹)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _gst,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'GST Rate (%)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _saveProduct,
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
    _rate.dispose();
    _gst.dispose();
    super.dispose();
  }
}