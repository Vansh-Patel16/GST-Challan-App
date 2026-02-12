class Invoice {
  int? id;
  final int clientId;
  final String date;
  final double totalAmount, gstAmount;
  final String? pdfPath;
  Invoice({
    this.id,
    required this.clientId,
    required this.date,
    required this.totalAmount,
    required this.gstAmount,
    this.pdfPath,
  });
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'clientId': clientId,
    'date': date,
    'totalAmount': totalAmount,
    'gstAmount': gstAmount,
    if (pdfPath != null) 'pdfPath': pdfPath
  };
  factory Invoice.fromMap(Map<String, dynamic> m) => Invoice(
      id: m['id'],
      clientId: m['clientId'],
      date: m['date'],
      totalAmount: m['totalAmount'],
      gstAmount: m['gstAmount'],
      pdfPath: m['pdfPath']);
}
