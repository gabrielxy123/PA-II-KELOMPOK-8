import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:carilaundry2/core/apiConstant.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _username;
  String? _userProfileImage;

  // Getter untuk status login dan data user
  bool get isLoggedIn => _token != null;
  String? get token => _token;
  String? get username => _username;
  String? get userProfileImage => _userProfileImage;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    if (_token != null) {
      // Lakukan request API untuk mendapatkan data user
      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/user-profil'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',          
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody['status'] == 'success') {
          final userData = responseBody['data'];
          _username = userData['name'];
          _userProfileImage = userData['profile_image'];
          notifyListeners();
        }
      }
    }
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
      } else {
        throw Exception('Login gagal: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat login: $e');
    }

    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    _token = null;
    _username = null;
    _userProfileImage = null;

    notifyListeners();
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
        _username = data['name'];
        _userProfileImage = data['profile_image'];

        // Simpan data user ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', _username!);
        await prefs.setString('profile_image', _userProfileImage!);
      } else {
        throw Exception('Gagal mengambil data user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil data user: $e');
    }
  }
}
