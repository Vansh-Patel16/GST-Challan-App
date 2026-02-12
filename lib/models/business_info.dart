class BusinessInfo {
  final String name;
  final String contact;
  final String companyName;
  final String gstNo;
  final String email;
  final String address;

  BusinessInfo({
    required this.name,
    required this.contact,
    required this.companyName,
    required this.gstNo,
    required this.email,
    required this.address,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'contact': contact,
    'companyName': companyName,
    'gstNo': gstNo,
    'email': email,
    'address': address,
  };

  factory BusinessInfo.fromMap(Map<String, dynamic> m) => BusinessInfo(
    name: m['name'] ?? '',
    contact: m['contact'] ?? '',
    companyName: m['companyName'] ?? '',
    gstNo: m['gstNo'] ?? '',
    email: m['email'] ?? '',
    address: m['address'] ?? '',
  );
}
