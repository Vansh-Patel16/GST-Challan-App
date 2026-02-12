import 'package:sqflite/sqflite.dart' show ConflictAlgorithm, Database, getDatabasesPath, openDatabase;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/client.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/business_info.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async => _database ??= await _initDB('app.db');

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE business_info(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          contact TEXT NOT NULL,
          companyName TEXT NOT NULL,
          gstNo TEXT NOT NULL,
          email TEXT NOT NULL,
          address TEXT NOT NULL)
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gstNo TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL)
    ''');
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        rate REAL NOT NULL,
        gstRate REAL NOT NULL)
    ''');
    await db.execute('''
      CREATE TABLE invoices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER NOT NULL,
        date TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        gstAmount REAL NOT NULL,
        pdfPath TEXT,
        FOREIGN KEY (clientId) REFERENCES clients (id) ON DELETE CASCADE)
    ''');
    await db.execute('''
      CREATE TABLE invoice_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        qty INTEGER NOT NULL,
        rate REAL NOT NULL,
        gstRate REAL NOT NULL,
        FOREIGN KEY (invoiceId) REFERENCES invoices (id) ON DELETE CASCADE)
    ''');
    await db.execute('''
        CREATE TABLE business_info(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          contact TEXT NOT NULL,
          companyName TEXT NOT NULL,
          gstNo TEXT NOT NULL,
          email TEXT NOT NULL,
          address TEXT NOT NULL)
      ''');
  }

  Future<int> updateBusinessInfo(BusinessInfo info) async {
    final db = await database;
    return await db.insert(
      'business_info',
      {'id': 1, ...info.toMap()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BusinessInfo?> getBusinessInfo() async {
    final db = await database;
    final res = await db.query('business_info', where: 'id = 1');
    if (res.isNotEmpty) {
      return BusinessInfo.fromMap(res.first);
    }
    return null;
  }

  Future<int> insertClient(Client client) async {
    final db = await database;
    return await db.insert('clients', client.toMap());
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update('clients', client.toMap(), where: 'id = ?', whereArgs: [client.id]);
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Client>> getClients() async {
    final db = await database;
    final res = await db.query('clients');
    return res.map((e) => Client.fromMap(e)).toList();
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final res = await db.query('products');
    return res.map((e) => Product.fromMap(e)).toList();
  }

  Future<int> insertInvoice(Invoice invoice) async {
    final db = await database;
    return await db.insert('invoices', invoice.toMap());
  }

  Future<int> deleteInvoice(int id) async {
    final db = await database;
    return await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Invoice>> getInvoices() async {
    final db = await database;
    final res = await db.query('invoices');
    return res.map((e) => Invoice.fromMap(e)).toList();
  }

  Future<int> insertInvoiceItem(InvoiceItem item) async {
    final db = await database;
    return await db.insert('invoice_items', item.toMap());
  }

  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    final db = await database;
    final res = await db.query(
      'invoice_items',
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
    );
    return res.map((e) => InvoiceItem.fromMap(e)).toList();
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
