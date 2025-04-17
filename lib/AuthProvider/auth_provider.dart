import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:carilaundry2/core/apiConstant.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _username;
  String? _userProfileImage;
  bool _isDisposed = true;
  bool _isCheckingLogin = true;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // Getter untuk status login dan data user
  bool get isCheckingLogin => _isCheckingLogin;
  String? get token => _token;
  String? get username => _username;
  String? get userProfileImage => _userProfileImage;

  Future<void> checkLoginStatus() async {
    _isCheckingLogin = true;
    _safeNotifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _username = prefs.getString('name');
    _userProfileImage = prefs.getString('profile_image');

    if (_token != null && (_username == null || _userProfileImage == null)) {
      // Jika token ada tapi data user belum tersedia, lakukan fetch
      await _fetchUserData();
    }

    _isCheckingLogin = false;
    _safeNotifyListeners();
  }

  Future<void> login(String username, String password) async {
    final url = Uri.parse('${Apiconstant.BASE_URL}/login');
    try {
      final response = await http.post(
        url,
        body: {
          'name': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];

        // Simpan token di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        _token = token;
        await _fetchUserData(); // Ambil data user setelah login
        _safeNotifyListeners();
      } else {
        print('Login gagal: ${response.body}');
        throw Exception('Login gagal: ${response.body}');
      }
    } catch (e) {
      print('Error saat login: $e');
      throw Exception('Error saat login: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data di SharedPreferences

    _token = null;
    _username = null;
    _userProfileImage = null;

    print('Logout berhasil');
    _safeNotifyListeners();
  }

  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  Future<void> _fetchUserData() async {
    final url = Uri.parse('${Apiconstant.BASE_URL}/user-profil');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Periksa jika data['name'] dan data['profile_image'] ada dan tidak null
        if (data['name'] != null && data['profile_image'] != null) {
          _username = data['name'] ??
              'Nama Tidak Tersedia'; // Berikan nilai default jika null
          _userProfileImage = data['profile_image']?.isNotEmpty == true
              ? data['profile_image'] // Jika profile_image tidak kosong
              : 'assets/default_profile_image.png'; // Gambar default jika kosong

          // Simpan data user ke SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'name', _username!); // Pastikan _username tidak null
          await prefs.setString('profile_image',
              _userProfileImage!); // Pastikan _userProfileImage tidak null

          _safeNotifyListeners(); // Pastikan notifyListeners dipanggil setelah data berhasil diperbarui
        } else {
          // Jika name atau profile_image null, beri nilai default
          _username = 'Nama Tidak Tersedia';
          _userProfileImage =
              'assets/default_profile_image.png'; // Gambar default

          // Simpan data user ke SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', _username!);
          await prefs.setString('profile_image', _userProfileImage!);

          _safeNotifyListeners();
        }
      } else {
        throw Exception('Gagal mengambil data user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil data user: $e');
    }
  }
}
