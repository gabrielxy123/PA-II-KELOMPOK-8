import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/custom_field.dart';
import 'package:carilaundry2/widgets/next_button.dart';
import 'package:carilaundry2/pages/form_informasi.dart';

class FormAlamatPage extends StatefulWidget {
  @override
  _AlamatState createState() => _AlamatState();
  const FormAlamatPage({super.key});
}

class _AlamatState extends State<FormAlamatPage>{
  TextEditingController provinsiController = TextEditingController();
  TextEditingController kabupatenController = TextEditingController();
  TextEditingController kecamatanController = TextEditingController();
  TextEditingController jalanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Formulir Alamat Toko", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("* Menunjukkan kolom yang wajib diisi", style: TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            CustomField(
             label: "*Alamat Jalan",
             controller: jalanController,
             isPassword: false,
             textInputType: TextInputType.streetAddress, 
             radius: 12),
            const SizedBox(height: 8,),
            CustomField(
             label: "*Kecamatan",
             controller: kecamatanController,
             isPassword: false,
             textInputType: TextInputType.streetAddress, 
             radius: 12),
            const SizedBox(height: 8,),
            CustomField(
             label: "*Kabupaten",
             controller: kabupatenController,
             isPassword: false,
             textInputType: TextInputType.streetAddress, 
             radius: 12),
            const SizedBox(height: 8,),
            CustomField(
             label: "*Provinsi",
             controller: provinsiController,
             isPassword: false,
             textInputType: TextInputType.streetAddress, 
             radius: 12),
            const SizedBox(height: 8,),
            const SizedBox(height: 20),
            NextButton(nextPage: FormInformasiPage()) 
          ],
        ),
      ),
    );
  }
}