import 'dart:convert';
import 'package:carilaundry2/controller/AuthController.dart';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/widgets/custom_field.dart';
import 'package:carilaundry2/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/app_button.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late Authcontroller _authcontroller;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authcontroller = Authcontroller();
  }

  void _register(
      String name, String email, String password, String phone) async {
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String phone = phoneController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      _showErrorDialog("Semua kolom harus diisi.");
      return;
    }

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

      if (response.statusCode == 201) {
        CustomSnackbar.showSuccess(context, "Pendaftaran berhasil!");
        Navigator.pushReplacementNamed(context, "/login");
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage =
            responseData['message'] ?? "Pendaftaran gagal. Coba lagi.";
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog(
          "Terjadi kesalahan. Periksa koneksi Anda dan coba lagi.");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Konten Utama dengan Scroll
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 60), // Memberi ruang untuk icon back
                  Center(
                    child: Column(
                      children: [
                        Image.asset('assets/images/logo.png', height: 110),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                  Text("Nama", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  CustomField(
                    label: 'Masukkan nama anda..',
                    controller: nameController,
                    isPassword: false,
                    textInputType: TextInputType.text,
                    radius: 10,
                  ),
                  SizedBox(height: 10),
                  Text("Kata Sandi",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 13),
                  CustomField(
                    label: 'Masukkan password anda..',
                    controller: passwordController,
                    isPassword: true,
                    textInputType: TextInputType.text,
                    radius: 10,
                  ),
                  SizedBox(height: 10),
                  Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 13),
                  CustomField(
                    label: 'Masukkan email anda..',
                    controller: emailController,
                    isPassword: false,
                    textInputType: TextInputType.emailAddress,
                    radius: 10,
                  ),
                  SizedBox(height: 10),
                  Text("No Telepon",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 13),
                  CustomField(
                    label: 'Masukkan nomor anda..',
                    controller: phoneController,
                    isPassword: false,
                    textInputType: TextInputType.phone,
                    radius: 10,
                  ),
                  SizedBox(height: 20),
                  AppButton(
                    type: ButtonType.PRIMARY,
                    text: "Daftar",
                    onPressed: () {
                      print("button ditekan");
                      _register(nameController.text, passwordController.text,
                          emailController.text, phoneController.text);
                    },
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/login");
                        },
                        child: RichText(
                            text: TextSpan(
                                text: "Sudah memiliki akun? ",
                                style: TextStyle(color: Colors.black),
                                children: [
                              TextSpan(
                                text: "Masuk",
                                style: TextStyle(color: Colors.green),
                              )
                            ]))),
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
              child: Icon(
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
