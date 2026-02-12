class Client {
  int? id;
  final String name, gstNo, address, phone;
  Client({this.id, required this.name, required this.gstNo, required this.address, required this.phone});
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'gstNo': gstNo,
    'address': address,
    'phone': phone
  };
  factory Client.fromMap(Map<String, dynamic> m) => Client(
      id: m['id'], name: m['name'], gstNo: m['gstNo'], address: m['address'], phone: m['phone']);
}

