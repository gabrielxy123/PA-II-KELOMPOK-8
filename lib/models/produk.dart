class Produk {
  final String id;
  final String nama;
  final String kategoriId;
  final int harga;
  int? quantity; // nullable for initialization
  final String? logoUrl;

  Produk({
    required this.id,
    required this.nama,
    required this.kategoriId,
    required this.harga,
    this.quantity = 0,
    this.logoUrl,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'].toString(),
      nama: json['nama'] ?? '',
      kategoriId: json['id_kategori'].toString(),
      harga: json['harga'] is int ? json['harga'] : int.tryParse(json['harga'].toString()) ?? 0,
      quantity: 0,
      logoUrl: json['logo_url'],
    );
  }

  @override
  String toString() {
    return 'Produk{id: $id, nama: $nama, kategoriId: $kategoriId, harga: $harga, quantity: $quantity}';
  }
}