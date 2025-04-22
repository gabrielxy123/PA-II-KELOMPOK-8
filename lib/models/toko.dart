class Toko {
  final String name;
  final String description;
  final String logo;
  final String price;

  Toko({
    required this.name,
    required this.description,
    required this.logo,
    required this.price,
  });

  factory Toko.fromJson(Map<String, dynamic> json) {
    return Toko(
      name: json['nama'] ?? '',
      description: json['deskripsi'] ?? '',
      logo: json['logo'] ?? '',
      price: json['price'] ?? '',
    );
  }
}