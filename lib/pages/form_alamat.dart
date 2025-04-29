import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/custom_field.dart';
import 'package:carilaundry2/pages/form_informasi.dart';

class FormAlamatPage extends StatefulWidget {
  final String name;
  final String phone;
  final String email;
  final String deskripsi;

  const FormAlamatPage({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.deskripsi,
  });

  @override
  _AlamatState createState() => _AlamatState();
}

class _AlamatState extends State<FormAlamatPage> {
  TextEditingController provinsiController = TextEditingController();
  TextEditingController kabupatenController = TextEditingController();
  TextEditingController kecamatanController = TextEditingController();
  TextEditingController jalanController = TextEditingController();

  // Validation function for address fields
  String? _validateAddressField(String value, String fieldName) {
    if (value.isEmpty) {
      return "$fieldName wajib diisi";
    }
    if (value.length > 255) {
      return "$fieldName maksimal 255 karakter";
    }
    return null;
  }

  void _goToNextPage() {
    final String provinsi = provinsiController.text;
    final String kabupaten = kabupatenController.text;
    final String kecamatan = kecamatanController.text;
    final String jalan = jalanController.text;

    // Validate all fields
    String? jalanError = _validateAddressField(jalan, "Alamat jalan");
    String? kecamatanError = _validateAddressField(kecamatan, "Kecamatan");
    String? kabupatenError = _validateAddressField(kabupaten, "Kabupaten");
    String? provinsiError = _validateAddressField(provinsi, "Provinsi");

    // Check if there are any validation errors
    if (jalanError != null || kecamatanError != null || 
        kabupatenError != null || provinsiError != null) {
      // Show the first error message
      String errorMessage = jalanError ?? kecamatanError ?? 
                           kabupatenError ?? provinsiError ?? "Validasi gagal";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    // If validation passes, navigate to FormInformasiPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormInformasiPage(
          name: widget.name,
          phone: widget.phone,
          email: widget.email,
          deskripsi: widget.deskripsi,
          jalan: jalan,
          kecamatan: kecamatan,
          kabupaten: kabupaten,
          provinsi: provinsi,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Formulir Alamat Toko",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Silahkan isi alamat toko laundry Anda dengan lengkap dan benar.",
                style: TextStyle(
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "* Menunjukkan kolom yang wajib diisi",
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              const Text(
                "Alamat Jalan *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              CustomField(
                label: "*Alamat Jalan",
                controller: jalanController,
                isPassword: false,
                textInputType: TextInputType.streetAddress,
                radius: 12,
              ),
              const SizedBox(height: 20),
              const Text(
                "Kecamatan *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              CustomField(
                label: "*Kecamatan",
                controller: kecamatanController,
                isPassword: false,
                textInputType: TextInputType.streetAddress,
                radius: 12,
              ),
              const SizedBox(height: 20),
              const Text(
                "Kabupaten *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              CustomField(
                label: "*Kabupaten",
                controller: kabupatenController,
                isPassword: false,
                textInputType: TextInputType.streetAddress,
                radius: 12,
              ),
              const SizedBox(height: 20),
              const Text(
                "Provinsi *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              CustomField(
                label: "*Provinsi",
                controller: provinsiController,
                isPassword: false,
                textInputType: TextInputType.streetAddress,
                radius: 12,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _goToNextPage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green.withOpacity(0.2),
                  foregroundColor: Colors.green,
                  elevation: 0,
                ),
                child: const Text(
                  "Selanjutnya",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}