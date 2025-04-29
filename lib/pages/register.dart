import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/widgets/custom_field.dart';
import 'package:carilaundry2/widgets/app_button.dart';
import 'package:carilaundry2/widgets/custom_snackbar.dart';

class Register extends StatefulWidget {
  const Register({super.key});

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
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ),
    );
  }

  // ---------- ERROR DIALOG (DEFAULT STYLE) ----------
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

  // ---------- REGISTER FUNCTION ----------
  Future<void> _register(String name, String password, String email, String phone) async {
    if (name.isEmpty) {
      _showErrorDialog("Nama tidak boleh kosong.");
      return;
    }
    if (email.isEmpty) {
      _showErrorDialog("Email wajib diisi.");
      return;
    }
    if (!email.contains("@") || !email.contains(".")) {
      _showErrorDialog("Format email tidak valid.");
      return;
    }
    if (password.isEmpty) {
      _showErrorDialog("Password wajib diisi.");
      return;
    }
    if (password.length < 6) {
      _showErrorDialog("Password minimal 6 karakter.");
      return;
    }
    if (phone.isEmpty) {
      _showErrorDialog("Nomor telepon wajib diisi.");
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showErrorDialog("Nomor telepon hanya boleh berisi angka.");
      return;
    }
    if (phone.length < 11 || phone.length > 15) {
      _showErrorDialog("Nomor telepon minimal 11 dan maksimal 15 angka.");
      return;
    }

    _showLoadingDialog();

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

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 201) {
        CustomSnackbar.showSuccess(context, "Pendaftaran berhasil!");
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, "/login");
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage = responseData['message'] ?? "Pendaftaran gagal. Coba lagi.";
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog("Terjadi kesalahan. Periksa koneksi Anda dan coba lagi.");
    }
  }

  // ---------- BUILD UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text("Nama", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  CustomField(
                    label: 'Masukkan nama anda..',
                    controller: nameController,
                    isPassword: false,
                    textInputType: TextInputType.text,
                    radius: 10,
                  ),
                  const SizedBox(height: 20),
                  const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  CustomField(
                    label: 'Masukkan email anda..',
                    controller: emailController,
                    isPassword: false,
                    textInputType: TextInputType.emailAddress,
                    radius: 10,
                  ),
                  const SizedBox(height: 20),
                  const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  CustomField(
                    label: 'Masukkan password anda..',
                    controller: passwordController,
                    isPassword: true,
                    textInputType: TextInputType.text,
                    radius: 10,
                  ),
                  const SizedBox(height: 20),
                  const Text("No Telepon", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  CustomField(
                    label: 'Masukkan no telepon anda..',
                    controller: phoneController,
                    isPassword: false,
                    textInputType: TextInputType.phone,
                    radius: 10,
                  ),
                  const SizedBox(height: 30),
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
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: RichText(
                        text: const TextSpan(
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
          Positioned(
            top: 40.0,
            left: 20.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                FlutterIcons.keyboard_backspace_mdi,
                color: Colors.black,
                size: 30.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
