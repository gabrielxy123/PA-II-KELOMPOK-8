import 'dart:convert';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/app_button.dart';  
import 'package:carilaundry2/widgets/custom_snackbar.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  // ---------- LOADING DIALOG ----------
  void _showLoadingDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- ERROR DIALOG ----------
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  // ---------- REGISTER FUNCTION ----------
  void _register(String name, String password, String email, String phone) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      _showErrorDialog("Semua kolom harus diisi.");
      return;
    }

    _showLoadingDialog(); // show loading

    try {
      final response = await http.post(
        Uri.parse('${Apiconstant.BASE_URL}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'noTelp': phone,
        }),
      );

      Navigator.pop(context); // close loading

      if (response.statusCode == 201) {
        CustomSnackbar.showSuccess(context, "Pendaftaran berhasil!");
        Navigator.pushReplacementNamed(context, "/login");
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage = responseData['message'] ?? "Pendaftaran gagal. Coba lagi.";
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      Navigator.pop(context); // close loading if error
      _showErrorDialog("Terjadi kesalahan. Periksa koneksi Anda dan coba lagi.");
    }
  }

  // ---------- BUILD UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 50),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                ),
              ),
              SizedBox(height: 30),
              Text("Nama", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              CustomField(
                label: 'Masukkan nama anda..',
                controller: nameController,
                isPassword: false,
                textInputType: TextInputType.text,
                radius: 10,
              ),
              SizedBox(height: 20),
              Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              CustomField(
                label: 'Masukkan email anda..',
                controller: emailController,
                isPassword: false,
                textInputType: TextInputType.emailAddress,
                radius: 10,
              ),
              SizedBox(height: 20),
              Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              CustomField(
                label: 'Masukkan password anda..',
                controller: passwordController,
                isPassword: true,
                textInputType: TextInputType.text,
                radius: 10,
              ),
              SizedBox(height: 20),
              Text("No Telepon", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              CustomField(
                label: 'Masukkan no telepon anda..',
                controller: phoneController,
                isPassword: false,
                textInputType: TextInputType.phone,
                radius: 10,
              ),
              SizedBox(height: 30),
              AppButton(
                type: ButtonType.PRIMARY,
                text: "Daftar",
                onPressed: () {
                  _register(
                    nameController.text,
                    passwordController.text,
                    emailController.text,
                    phoneController.text,
                  );
                },
              ),
              SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Sudah punya akun? ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Login sekarang",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
