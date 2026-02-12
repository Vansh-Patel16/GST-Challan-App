class Product {
  int? id;
  final String name;
  final double rate, gstRate;
  Product({this.id, required this.name, required this.rate, required this.gstRate});
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'rate': rate,
    'gstRate': gstRate
  };
  factory Product.fromMap(Map<String, dynamic> m) => Product(
      id: m['id'], name: m['name'], rate: m['rate'], gstRate: m['gstRate']);
}

