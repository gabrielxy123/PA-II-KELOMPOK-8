class Layanan {
  final String id;
  final String nama;
  final int harga;
  final String? logoUrl;


  Layanan({
    required this.id,
    required this.nama,
    required this.harga,
    this.logoUrl,
  });

  factory Layanan.fromJson(Map<String, dynamic> json) {
    return Layanan(
      id: json['id'].toString(),
      nama: json['nama'] ?? '',
      harga: json['harga'] is int ? json['harga'] : int.tryParse(json['harga'].toString()) ?? 0,
      logoUrl: json['logo_url'],  
    );
  }

  @override
  String toString() {
    return 'Layanan{id: $id, nama: $nama, harga: $harga,}';
  }
}