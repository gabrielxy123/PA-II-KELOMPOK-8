import 'dart:convert';
import 'package:carilaundry2/controller/AuthController.dart';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:carilaundry2/utils/constants.dart';
import 'package:carilaundry2/utils/helper.dart';
import 'package:carilaundry2/widgets/app_button.dart';
import 'package:carilaundry2/widgets/input_widget.dart';
import 'package:carilaundry2/widgets/custom_snackbar.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late Authcontroller _authcontroller;
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authcontroller = Authcontroller();
  }

  void _login(String name, String password) async {
    if (name.isEmpty) {
      _showErrorDialog("Nama harus diisi.");
      return;
    }

    if (password.isEmpty) {
      _showErrorDialog("Password harus diisi.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Apiconstant.BASE_URL}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String userName = responseData['user']['name'];
        CustomSnackbar.showSuccess(context, "Login Berhasil!");

        Navigator.pushReplacementNamed(
          context,
          "/dashboard",
          arguments: userName, // Kirim nama pengguna sebagai argumen
        );
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage =
            responseData['message'] ?? "Login gagal. Periksa data Anda";
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog(
        "Terjadi kesalahan. Periksa koneksi Anda dan coba lagi.",
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png', // Ganti dengan logo sesuai gambar
                        height: 110,
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
                Text("Nama", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 13),
                CustomField(
                  label: 'Masukkan nama anda..',
                  controller: nameController,
                  isPassword: false,
                  textInputType: TextInputType.text,
                  radius: 10,
                ),
                SizedBox(height: 20),
                Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 13),
                CustomField(
                  label: 'Masukkan password anda..',
                  controller: passwordController,
                  isPassword: true,
                  textInputType: TextInputType.text,
                  radius: 10,
                ),
                SizedBox(height: 20),
                AppButton(
                  type: ButtonType.PRIMARY,
                  text: "Masuk",
                  onPressed: () {
                    print("button di press");
                    _login(nameController.text, passwordController.text);
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/register");
                    },
                    child: Text(
                      "Belum punya akun?",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ],
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
