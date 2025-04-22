import 'dart:convert';
import 'package:carilaundry2/controller/AuthController.dart';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carilaundry2/widgets/app_button.dart';
import 'package:carilaundry2/widgets/custom_snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:carilaundry2/pages/admin/request_list.dart';

class Login extends StatefulWidget {
  const Login({super.key});

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
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ---------- LOGIN FUNCTION ----------
  void _login(String name, String password) async {
    if (name.isEmpty) {
      _showErrorDialog("Nama harus diisi.");
      return;
    }

    if (password.isEmpty) {
      _showErrorDialog("Password harus diisi.");
      return;
    }

    _showLoadingDialog(); // show loading

    try {
      final response = await http.post(
        Uri.parse('${Apiconstant.BASE_URL}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'password': password}),
      );

      Navigator.pop(context); // close loading

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        String token = responseData['token'] ?? '';
        if (token.isEmpty)
          throw Exception('Token tidak ditemukan di respons API');

        String userName = responseData['user']['name'] ?? 'Guest';
        String userProfileImage = responseData['user']['profile_image'] ?? '';
        int userId =
            responseData['user']['id']; // Ambil user_id dari respons API
        String role = responseData['role'] ?? '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', userName);
        await prefs.setString('userProfileImage', userProfileImage);
        await prefs.setString('auth_token', token);
        await prefs.setInt('user_id', userId); // Simpan user_id

        await _fetchUserProfile(token);

        CustomSnackbar.showSuccess(context, "Login Berhasil!");

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RequestListPage()),
          );
        } else {
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => Dashboard(userName: userName),
          //   ),
          //   (route) => false, // This will remove all previous routes
          // );
          Navigator.of(context) .pushNamedAndRemoveUntil("/dashboard", (route) => false);
        }
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage =
            responseData['message'] ?? "Login gagal. Periksa data Anda";
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      Navigator.pop(context); // close loading on error
      _showErrorDialog(
          "Terjadi kesalahan. Periksa koneksi Anda dan coba lagi.");
    }
  }

  Future<void> _fetchUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/user-profil'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final profileData = data['data'];
          String profileImage = profileData['profile_image'] ?? '';

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userProfileImage', profileImage);
        }
      }
    } catch (e) {
      print('Error fetching user profile after login: $e');
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

  // ---------- BUILD UI ----------
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
                        'assets/images/logo.png',
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
                    child: RichText(
                      text: TextSpan(
                        text: "Belum memiliki akun? ",
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Daftar sekarang",
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
