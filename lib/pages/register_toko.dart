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

  // Validation function for name
  String? _validateName(String value) {
    if (value.isEmpty) {
      return "Nama toko wajib diisi";
    }
    if (value.length > 255) {
      return "Nama toko maksimal 255 karakter";
    }
    return null;
  }

  // Validation function for phone number
  String? _validatePhone(String phone) {
    if (phone.isEmpty) {
      return "Nomor telepon wajib diisi";
    }
    
    RegExp phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(phone)) {
      return "Nomor telepon harus 10-15 digit angka";
    }
    return null;
  }

  // Validation function for email
  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return "Email wajib diisi";
    }
    
    RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    if (!emailRegex.hasMatch(value)) {
      return "Format email tidak valid";
    }
    
    if (value.length > 255) {
      return "Email maksimal 255 karakter";
    }
    return null;
  }

  // Validation function for description
  String? _validateDeskripsi(String value) {
    // Description is nullable, so empty is allowed
    if (value.isNotEmpty && value.length > 500) {
      return "Deskripsi maksimal 500 karakter";
    }
    return null;
  }

  void _goToNextPage() {
    final String name = nameController.text;
    final String phone = noTelpController.text;
    final String email = emailController.text;
    final String deskripsi = deskripsiController.text;

    // Validate all fields
    String? nameError = _validateName(name);
    String? phoneError = _validatePhone(phone);
    String? emailError = _validateEmail(email);
    String? deskripsiError = _validateDeskripsi(deskripsi);

    // Check if there are any validation errors
    if (nameError != null || phoneError != null || emailError != null || deskripsiError != null) {
      // Show the first error message
      String errorMessage = nameError ?? phoneError ?? emailError ?? deskripsiError ?? "Validasi gagal";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    // If validation passes, navigate to FormAlamatPage
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
      body: SingleChildScrollView(
        child: Padding(
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
                "Selamat Datang di halaman formulir pendaftaran toko CariLaundry. Disini adalah titik awal untuk mendaftarkan toko anda.",
                style: TextStyle(
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "* Menunjukkan kolom yang wajib diisi",
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
              const Text(
                "Nama Toko *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              CustomField(
                label: "*Nama Toko",
                controller: nameController,
                isPassword: false,
                textInputType: TextInputType.text,
                radius: 10,
              ),
              const SizedBox(height: 20),
              const Text(
                "Nomor Telepon *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              CustomField(
                label: "*Nomor Telepon",
                controller: noTelpController,
                isPassword: false,
                textInputType: TextInputType.phone,
                radius: 12,
              ),
              const SizedBox(height: 20),
              const Text(
                "Email (Contoh : abc@gmail.com) *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              CustomField(
                label: "*Email",
                controller: emailController,
                isPassword: false,
                textInputType: TextInputType.emailAddress,
                radius: 12,
              ),
              const SizedBox(height: 20),
              const Text(
                "Deskripsi Toko *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
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