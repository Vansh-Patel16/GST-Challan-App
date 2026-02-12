class InvoiceItem {
  final String productName;
  final int qty;
  final double rate, gstRate;
  final int? invoiceId;  // Add this to link to Invoice

  InvoiceItem({
    required this.productName,
    required this.qty,
    required this.rate,
    required this.gstRate,
    this.invoiceId,
  });

  double get total => qty * rate * (1 + gstRate / 100);

  // Add these for DB storage
  Map<String, dynamic> toMap() => {
    'invoiceId': invoiceId,
    'productName': productName,
    'qty': qty,
    'rate': rate,
    'gstRate': gstRate,
  };

  factory InvoiceItem.fromMap(Map<String, dynamic> m) => InvoiceItem(
    invoiceId: m['invoiceId'],
    productName: m['productName'],
    qty: m['qty'],
    rate: m['rate'],
    gstRate: m['gstRate'],
  );
}
