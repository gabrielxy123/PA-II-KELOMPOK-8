import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/custom_field.dart';
import 'package:carilaundry2/pages/form_alamat.dart';

class FormTokoPage extends StatefulWidget {
  const FormTokoPage({super.key});

  @override
  _TokoState createState() => _TokoState();
}

class _TokoState extends State<FormTokoPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController noTelpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();

  void _goToNextPage() {
    final String name = nameController.text;
    final String phone = noTelpController.text;
    final String email = emailController.text;
    final String deskripsi = deskripsiController.text;

    // Validasi input
    if (name.isEmpty || phone.isEmpty || email.isEmpty || deskripsi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua kolom harus diisi!")),
      );
      return;
    }

    // Navigasi ke FormAlamatPage dengan data yang diteruskan
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormAlamatPage(
          name: name,
          phone: phone,
          email: email,
          deskripsi: deskripsi,
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
              "Formulir Pendaftaran Toko",
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
              label: "*Nama Toko",
              controller: nameController,
              isPassword: false,
              textInputType: TextInputType.text,
              radius: 10,
            ),
            const SizedBox(height: 8),
            CustomField(
              label: "*Nomor Telepon",
              controller: noTelpController,
              isPassword: false,
              textInputType: TextInputType.phone,
              radius: 12,
            ),
            const SizedBox(height: 8),
            CustomField(
              label: "*Email",
              controller: emailController,
              isPassword: false,
              textInputType: TextInputType.emailAddress,
              radius: 12,
            ),
            const SizedBox(height: 8),
            CustomField(
              label: "*Deskripsi Toko",
              controller: deskripsiController,
              isPassword: false,
              textInputType: TextInputType.text,
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
