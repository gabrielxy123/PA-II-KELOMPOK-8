import 'dart:convert';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/custom_field.dart';
import 'package:http/http.dart' as http;
import 'package:carilaundry2/widgets/custom_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormInformasiPage extends StatefulWidget {
  final String name;
  final String phone;
  final String email;
  final String deskripsi;
  final String jalan;
  final String kecamatan;
  final String kabupaten;
  final String provinsi;

  const FormInformasiPage({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.deskripsi,
    required this.jalan,
    required this.kecamatan,
    required this.kabupaten,
    required this.provinsi,
  });

  @override
  _OperasionalState createState() => _OperasionalState();
}

class _OperasionalState extends State<FormInformasiPage> {
  TextEditingController waktuBukaController = TextEditingController();
  TextEditingController waktuTutupController = TextEditingController();

  // ---------- ERROR DIALOG ----------
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ---------- LOADING DIALOG ----------
  void _showLoadingDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ),
    );
  }

  // 1. Tambahkan fungsi getUserId()
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    print('User ID yang diambil dari SharedPreferences: $userId');
    return userId;
  }

  // 2. Fungsi getToken yang sudah ada
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void _registerToko(
    String name,
    String phone,
    String email,
    String deskripsi,
    String jalan,
    String kecamatan,
    String kabupaten,
    String provinsi,
    String waktuBuka,
    String waktuTutup,
  ) async {
    final token = await getToken();
    final userId = await getUserId();

    if (token == null) {
      _showErrorDialog("Sesi telah berakhir. Silahkan login kembali");
      return;
    }

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        deskripsi.isEmpty ||
        jalan.isEmpty ||
        kecamatan.isEmpty ||
        kabupaten.isEmpty ||
        provinsi.isEmpty ||
        waktuBuka.isEmpty ||
        waktuTutup.isEmpty) {
      _showErrorDialog("Semua kolom harus diisi.");
      return;
    }
  
  // Validate times before proceeding
  if (!_validateTimes()) {
    return;
  }

  _showLoadingDialog();

  try {
    final token = await getToken();
    final userId = await getUserId();
    print('User ID yang akan dikirim: $userId');
    final response = await http.post(
      Uri.parse('${Apiconstant.BASE_URL}/store'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer $token', // Ganti $token dengan token sebenarnya
      },
      body: jsonEncode({
        'user_id': userId,
        'nama': name,
        'noTelp': phone,
        'email': email,
        'deskripsi': deskripsi,
        'jalan': jalan,
        'kecamatan': kecamatan,
        'kabupaten': kabupaten,
        'provinsi': provinsi,
        'waktuBuka': waktuBuka,
        'waktuTutup': waktuTutup,
      }),
    );

    Navigator.pop(context);

    if (response.statusCode == 201) {
      CustomSnackbar.showSuccess(context, "Pendaftaran Toko Berhasil. Silahkan bayar uang sewa toko anda.");
      Navigator.pushReplacementNamed(context, "/upload-pembayaran");
    } else {
      final responseData = jsonDecode(response.body);
      String errorMessage =
          responseData['message'] ?? "Pendaftaran gagal. Coba lagi.";
      _showErrorDialog(errorMessage);
    }
  } catch (e) {
    Navigator.pop(context); // close loading if error
    _showErrorDialog(
        "Terjadi kesalahan. Periksa koneksi Anda dan coba lagi.");
  }
}

  // Tambahkan fungsi untuk menampilkan time picker
  Future<void> _selectTime(BuildContext context, bool isBuka) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        // Format waktu menjadi HH:MM:SS
        final hours = picked.hour.toString().padLeft(2, '0');
        final minutes = picked.minute.toString().padLeft(2, '0');
        final formattedTime = '$hours:$minutes:00';

        if (isBuka) {
          waktuBukaController.text = formattedTime;
        } else {
          waktuTutupController.text = formattedTime;
        }
      
      // Validate times if both fields are filled
      if (waktuBukaController.text.isNotEmpty && waktuTutupController.text.isNotEmpty) {
        _validateTimes();
      }
    });
  }
}

// Validate that closing time is after opening time
bool _validateTimes() {
  if (waktuBukaController.text.isEmpty || waktuTutupController.text.isEmpty) {
    return true; // Skip validation if either field is empty
  }
  
  // Parse the times
  final bukaParts = waktuBukaController.text.split(':');
  final tutupParts = waktuTutupController.text.split(':');
  
  if (bukaParts.length < 2 || tutupParts.length < 2) {
    return true; // Skip validation if format is incorrect
  }
  
  final bukaHour = int.parse(bukaParts[0]);
  final bukaMinute = int.parse(bukaParts[1]);
  final tutupHour = int.parse(tutupParts[0]);
  final tutupMinute = int.parse(tutupParts[1]);
  
  // Error Validation klo waktu buka diatas waktu tutup
  if (tutupHour < bukaHour || (tutupHour == bukaHour && tutupMinute <= bukaMinute)) {
    _showErrorDialog("Waktu tutup tidak boleh sebelum waktu buka");
    return false;
  }
  
  return true;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Formulir Informasi Toko",
              style: TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Terakhir, silahkan masukkan jam operasional toko laundry anda.",
            ),
            const SizedBox(height: 10),
            const Text(
              "* Menunjukkan kolom yang wajib diisi",
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            // Untuk Waktu Buka
            GestureDetector(
              onTap: () => _selectTime(context, true),
              child: AbsorbPointer(
                child: CustomField(
                  label: "*Waktu Buka",
                  controller: waktuBukaController,
                  isPassword: false,
                  textInputType: TextInputType.datetime,
                  radius: 12,
                  hintText: "Pilih Waktu Buka (HH:MM:SS)",
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Untuk Waktu Tutup
            GestureDetector(
              onTap: () => _selectTime(context, false),
              child: AbsorbPointer(
                child: CustomField(
                  label: "*Waktu Tutup",
                  controller: waktuTutupController,
                  isPassword: false,
                  textInputType: TextInputType.datetime,
                  radius: 12,
                  hintText: "Pilih Waktu Tutup (HH:MM:SS)",
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _registerToko(
                  widget.name,
                  widget.phone,
                  widget.email,
                  widget.deskripsi,
                  widget.jalan,
                  widget.kecamatan,
                  widget.kabupaten,
                  widget.provinsi,
                  waktuBukaController.text,
                  waktuTutupController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green.withOpacity(0.2),
                  foregroundColor: Colors.green,
                  elevation: 0,
                ),
              child: const Text(
                  "Daftarkan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
