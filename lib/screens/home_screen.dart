import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import '../providers/invoice_provider.dart';
import 'add_client_screen.dart';
import 'add_product_screen.dart';
import 'create_invoice_screen.dart';
import 'my_info_screen.dart';
import 'view_pdf_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    final prov = Provider.of<InvoiceProvider>(context, listen: false);
    prov.loadClients();
    prov.loadProducts();
    prov.loadInvoices();
    prov.loadBusinessInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Clients'),
            Tab(text: 'Products'),
            Tab(text: 'Invoices'),
            Tab(text: 'My Info')
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 3
          ? null
          : FloatingActionButton(
              onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddClientScreen()),
            );
          } else if (_tabController.index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            );
          } else if (_tabController.index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<InvoiceProvider>(
        builder: (_, prov, __) => TabBarView(
          controller: _tabController,
          children: [
            ListView.builder(
              itemCount: prov.clients.length,
              itemBuilder: (_, i) {
                final client = prov.clients[i];
                return ListTile(
                  title: Text(client.name),
                  subtitle: Text(client.gstNo),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddClientScreen(client: client)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => prov.deleteClient(client.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListView.builder(
              itemCount: prov.products.length,
              itemBuilder: (_, i) {
                final product = prov.products[i];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('₹${product.rate} - GST: ${product.gstRate}%'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddProductScreen(product: product)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => prov.deleteProduct(product.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListView.builder(
              itemCount: prov.invoices.length,
              itemBuilder: (_, i) {
                final inv = prov.invoices[i];
                return ListTile(
                  title: Text('Inv #${inv.id}'),
                  subtitle: Text(inv.date),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => prov.deleteInvoice(inv.id!),
                  ),
                  onTap: () {
                    if (inv.pdfPath != null) {
                      final invoiceFile = File(inv.pdfPath!);
                      if (invoiceFile.existsSync()) {
                        // Infer challan path from invoice path (they share the same timestamp)
                        final directory = invoiceFile.parent.path;
                        final fileName = p.basename(inv.pdfPath!);
                        final challanName = fileName.replaceFirst('inv_', 'challan_');
                        final challanPath = p.join(directory, challanName);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewPdfScreen(
                              invoicePath: inv.pdfPath!,
                              challanPath: challanPath,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PDF file not found.')),
                        );
                      }
                    }
                  },
                );
              },
            ),
            const MyInfoTab(),
          ],
        ),
      ),
    );
  }
}