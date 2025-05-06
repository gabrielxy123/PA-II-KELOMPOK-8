class Laundry {
  final int id;
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
  final String logo;

  Laundry({
    required this.id,
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
    required this.logo,
  });

  factory Laundry.fromJson(Map<String, dynamic> json) {
    // Fungsi helper untuk parse waktu
    DateTime parseWaktu(String waktuStr) {
      try {
        // Format waktu dari API: "HH:MM:SS" atau "HH:MM"
        final timeParts = waktuStr.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
        
        // Kita gunakan tanggal hari ini sebagai placeholder
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute);
      } catch (e) {
        print('Error parsing waktu: $e');
        return DateTime.now(); // Fallback ke waktu sekarang
      }
    }

    return Laundry(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      noTelp: json['noTelp'] ?? '',
      email: json['email'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      jalan: json['jalan'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      kabupaten: json['kabupaten'] ?? '',
      provinsi: json['provinsi'] ?? '',
      waktuBuka: parseWaktu(json['waktuBuka']?.toString() ?? '08:00'), // Default 08:00 jika null
      waktuTutup: parseWaktu(json['waktuTutup']?.toString() ?? '17:00'), // Default 17:00 jika null
      buktiBayar: json['buktiBayar'] ?? '',
      Status: json['status'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}