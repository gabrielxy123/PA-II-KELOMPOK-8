import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/custom_field.dart';

class FormInformasiPage extends StatefulWidget {
  _OperasionalState createState() => _OperasionalState();
  const FormInformasiPage({super.key});
}

class _OperasionalState extends State<FormInformasiPage>{
  TextEditingController waktuBukaController = TextEditingController();
  TextEditingController waktuTutupController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Formulir Informasi Toko", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("* Menunjukkan kolom yang wajib diisi", style: TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            CustomField(
              label: "*Waktu Buka", 
              controller: waktuBukaController, 
              isPassword: false, 
              textInputType: TextInputType.datetime, 
              radius: 12),
            const SizedBox(height: 8),
            CustomField(
              label: "*Waktu Tutup", 
              controller: waktuTutupController, 
              isPassword: false, 
              textInputType: TextInputType.datetime, 
              radius: 12),
            const SizedBox(height: 8),
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