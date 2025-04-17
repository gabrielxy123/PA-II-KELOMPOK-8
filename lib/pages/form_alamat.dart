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

  void _goToNextPage() {
    final String provinsi = provinsiController.text;
    final String kabupaten = kabupatenController.text;
    final String kecamatan = kecamatanController.text;
    final String jalan = jalanController.text;

    if (provinsi.isEmpty || kabupaten.isEmpty || kecamatan.isEmpty || jalan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua kolom harus diisi!")),
      );
      return;
    }

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
      body: Padding(
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
              "* Menunjukkan kolom yang wajib diisi",
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 20),
            CustomField(
              label: "*Alamat Jalan",
              controller: jalanController,
              isPassword: false,
              textInputType: TextInputType.streetAddress,
              radius: 12,
            ),
            const SizedBox(height: 8),
            CustomField(
              label: "*Kecamatan",
              controller: kecamatanController,
              isPassword: false,
              textInputType: TextInputType.streetAddress,
              radius: 12,
            ),
            const SizedBox(height: 8),
            CustomField(
              label: "*Kabupaten",
              controller: kabupatenController,
              isPassword: false,
              textInputType: TextInputType.streetAddress,
              radius: 12,
            ),
            const SizedBox(height: 8),
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
              ),
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
