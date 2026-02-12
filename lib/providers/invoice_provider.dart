import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/client.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/business_info.dart';

class InvoiceProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Client> _clients = [];
  List<Product> _products = [];
  List<Invoice> _invoices = [];
  BusinessInfo? _businessInfo;

  List<Client> get clients => _clients;
  List<Product> get products => _products;
  List<Invoice> get invoices => _invoices;
  BusinessInfo? get businessInfo => _businessInfo;

  Future<void> loadBusinessInfo() async {
    _businessInfo = await _db.getBusinessInfo();
    notifyListeners();
  }

  Future<void> updateBusinessInfo(BusinessInfo info) async {
    await _db.updateBusinessInfo(info);
    _businessInfo = info;
    notifyListeners();
  }

  Future<void> loadClients() async {
    _clients = await _db.getClients();
    notifyListeners();
  }

  Future<void> addClient(Client c) async {
    await _db.insertClient(c);
    await loadClients();
  }

  Future<void> updateClient(Client c) async {
    await _db.updateClient(c);
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    await _db.deleteClient(id);
    await loadClients();
  }

  Future<void> loadProducts() async {
    _products = await _db.getProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product p) async {
    await _db.insertProduct(p);
    await loadProducts();
  }

  Future<void> updateProduct(Product p) async {
    await _db.updateProduct(p);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _db.deleteProduct(id);
    await loadProducts();
  }

  Future<void> loadInvoices() async {
    _invoices = await _db.getInvoices();
    notifyListeners();
  }

  Future<void> deleteInvoice(int id) async {
    await _db.deleteInvoice(id);
    await loadInvoices();
  }

  Future<void> saveInvoice(Invoice inv, List<InvoiceItem> items) async {
    final id = await _db.insertInvoice(inv);
    for (var item in items) {
      item = InvoiceItem(
        invoiceId: id,
        productName: item.productName,
        qty: item.qty,
        rate: item.rate,
        gstRate: item.gstRate,
      );
      await _db.insertInvoiceItem(item);
    }
    await loadInvoices();
  }

  double calculateTotal(List<InvoiceItem> items) =>
      items.fold(0, (sum, item) => sum + (item.qty * item.rate));

  double calculateGST(List<InvoiceItem> items) =>
      items.fold(0, (sum, item) => sum + (item.qty * item.rate * item.gstRate / 100));
}