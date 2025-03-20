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

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String token = responseData['token'] ?? '';
        if (token.isEmpty) {
          throw Exception('Token tidak ditemukan di respons API');
        }
        String userName = responseData['user']['name'] ?? 'Guest';
        String userProfileImage = responseData['user']['profile_image'] ?? '';

        print('Login successful - userName: $userName');
        print('Login successful - userProfileImage: $userProfileImage');

        // Simpan data pengguna di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', userName);
        await prefs.setString('userProfileImage', userProfileImage);
        await prefs.setString('auth_token', token);

        // Fetch full profile after login to ensure we have all data
        await _fetchUserProfile(token);

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
      print('Login error: $e');
      _showErrorDialog(
        "Terjadi kesalahan. Periksa koneksi Anda dan coba lagi.",
      );
    }
  }

  // Fetch complete user profile data after login
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

      print('Profile fetch response status: ${response.statusCode}');
      print('Profile fetch response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final profileData = data['data'];
          String profileImage = profileData['profile_image'] ?? '';

          print('Fetched profile image URL: $profileImage');

          // Update SharedPreferences with the latest profile data
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
