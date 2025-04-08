import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FormTokoPage(),
    );
  }
}

class FormTokoPage extends StatelessWidget {
  const FormTokoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulir Pendaftaran Toko")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Formulir Pendaftaran Toko", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("* Menunjukkan kolom yang wajib diisi", style: TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            _buildTextField("Nama Toko *"),
            _buildTextField("No Telepon *"),
            _buildTextField("Email"),
            _buildTextField("Deskripsi Toko"),
            const SizedBox(height: 20),
            _buildNextButton(context, const FormAlamatPage()),
          ],
        ),
      ),
    );
  }
}

class FormAlamatPage extends StatelessWidget {
  const FormAlamatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulir Alamat Toko")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Formulir Alamat Toko", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("* Menunjukkan kolom yang wajib diisi", style: TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            _buildTextField("Alamat Jalan *"),
            _buildTextField("Kecamatan/Kelurahan *"),
            _buildTextField("Kabupaten/Kota *"),
            _buildTextField("Provinsi *"),
            const SizedBox(height: 20),
            _buildNextButton(context, const FormInformasiPage()),
          ],
        ),
      ),
    );
  }
}

class FormInformasiPage extends StatelessWidget {
  const FormInformasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulir Informasi Toko")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Formulir Informasi Toko", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("* Menunjukkan kolom yang wajib diisi", style: TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            _buildDropdownField("Hari Operasional *"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
Widget _buildTextField(String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
Widget _buildDropdownField(String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: const [DropdownMenuItem(value: "Senin - Jumat", child: Text("Senin - Jumat")), DropdownMenuItem(value: "Sabtu - Minggu", child: Text("Sabtu - Minggu"))],
      onChanged: (value) {},
    ),
  );
}
Widget _buildNextButton(BuildContext context, Widget nextPage) {
  return ElevatedButton(
    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => nextPage)),
    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
    child: const Text("Selanjutnya"),
  );
}
