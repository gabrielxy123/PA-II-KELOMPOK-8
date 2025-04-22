class Laundry {
  final String nama;
  final String noTelp;
  final String email;
  final String deskripsi;
  final String jalan;
  final String kecamatan;
  final String kabupaten;
  final String provinsi;
  final DateTime waktuBuka;
  final DateTime waktuTutup;
  final String buktiBayar;
  final String Status;

  Laundry({
    required this.nama,
    required this.noTelp,
    required this.email,
    required this.deskripsi,
    required this.jalan,
    required this.kecamatan,
    required this.kabupaten,
    required this.provinsi,
    required this.waktuBuka,
    required this.waktuTutup,
    required this.buktiBayar,
    required this.Status,
  });

  factory Laundry.fromJson(Map<String, dynamic> json){
    return Laundry(
      nama: json['nama'] ?? '',
      noTelp: json['noTelp'] ?? '',
      email: json['email'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      jalan: json['jalan'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      kabupaten: json['kabupaten'] ?? '',
      provinsi: json['provinsi'] ?? '',
      waktuBuka: json['waktuBuka'] ?? '',
      waktuTutup: json['waktuTutup'] ?? '',
      buktiBayar: json['buktiBayar'] ?? '',
      Status: json['status'] ?? '',
    );
  }
}