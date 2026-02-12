import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/client.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../providers/invoice_provider.dart';
import '../pdf/invoice_pdf.dart';
import 'view_pdf_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});
  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}
class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  Client? selectedClient;
  final List<InvoiceItem> items = [];
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<InvoiceProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Invoice')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          DropdownButton<Client>(
              hint: const Text('Select Client'),
              value: selectedClient,
              items: prov.clients
                  .map((c) => DropdownMenuItem(
                  value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (c) => setState(() => selectedClient = c)),
          DropdownButton<Product>(
              hint: const Text('Add Product'),
              items: prov.products
                  .map((p) => DropdownMenuItem(
                  value: p, child: Text(p.name)))
                  .toList(),
              onChanged: (p) {
                if (p == null) return;
                setState(() => items.add(InvoiceItem(
                    productName: p.name,
                    qty: 1,
                    rate: p.rate,
                    gstRate: p.gstRate)));
              }),
          Expanded(
              child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) => ListTile(
                      title: Text(items[i].productName),
                      subtitle: Text(
                          'Qty ${items[i].qty}  Rate ₹${items[i].rate}  GST ${items[i].gstRate}%'),
                      trailing: Text('₹${items[i].total.toStringAsFixed(2)}')))),
          const Divider(),
          Text('Sub-total: ₹${prov.calculateTotal(items).toStringAsFixed(2)}'),
          Text('GST: ₹${prov.calculateGST(items).toStringAsFixed(2)}'),
          Text('Grand: ₹${(prov.calculateTotal(items) + prov.calculateGST(items)).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('GENERATE PDF'),
              onPressed: () async {
                if (selectedClient == null || items.isEmpty) return;
                final gst = prov.calculateGST(items);
                final total = prov.calculateTotal(items);
                final businessInfo = prov.businessInfo;

                final invoiceBytes = await generateInvoicePDF(
                    businessInfo: businessInfo,
                    client: selectedClient!,
                    items: items,
                    gst: gst,
                    total: total);

                final challanBytes = await generateChallanPDF(
                    businessInfo: businessInfo,
                    client: selectedClient!,
                    items: items);

                final dir = await getApplicationDocumentsDirectory();
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final invoiceFile = File('${dir.path}/inv_$timestamp.pdf');
                final challanFile = File('${dir.path}/challan_$timestamp.pdf');

                await invoiceFile.writeAsBytes(invoiceBytes);
                await challanFile.writeAsBytes(challanBytes);

                final inv = Invoice(
                    clientId: selectedClient!.id!,
                    date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
                    totalAmount: total,
                    gstAmount: gst,
                    pdfPath: invoiceFile.path);
                await prov.saveInvoice(inv, items);

                if (!mounted) return;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ViewPdfScreen(
                              invoicePath: invoiceFile.path,
                              challanPath: challanFile.path,
                            )));
              })
        ]),
      ),
    );
  }
}