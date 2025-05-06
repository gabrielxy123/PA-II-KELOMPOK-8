class Kategori {
  final String id;
  final String kategori;

  Kategori({
    required this.id,
    required this.kategori,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'].toString(),
      kategori: json['kategori'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Kategori{id: $id, kategori: $kategori}';
  }
}