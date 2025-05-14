import 'dart:convert';
import 'dart:io';

import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/models/userProfile.dart';
import 'package:carilaundry2/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carilaundry2/AuthProvider/auth_provider.dart'; // Pastikan path benar
import 'package:carilaundry2/pages/notifikasi.dart';
import 'package:carilaundry2/pages/not_logged.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TopBarWidget extends StatefulWidget {
  final bool isLoggedIn; // Status login
  final String? userName; // Nama pengguna (jika sudah login)
  final String? userProfileImage; // Gambar profil pengguna (jika sudah login)

  const TopBarWidget({
    super.key,
    this.isLoggedIn = false,
    this.userName,
    this.userProfileImage,
  });

  @override
  State<TopBarWidget> createState() => _TopBarWidgetState();
}

class _TopBarWidgetState extends State<TopBarWidget> {
  late Future<UserProfile?> userProfileFuture;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    // print('TopBarWidget - isLoggedIn: ${widget.isLoggedIn}');
    // print('TopBarWidget - userProfileImage: ${widget.userProfileImage}');
    userProfileFuture = _checkLoginAndFetchProfile();
  }

  Future<UserProfile?> _checkLoginAndFetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      print('token: $token');

      if (token.isEmpty) {
        print('Token is empty, user not logged in');
        return null;
      }

      return await fetchUserProfile();
    } catch (e) {
      print('Error checking login status: $e');
      return null;
    }
  }

  Future<UserProfile> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      print('token: $token');

      if (token.isEmpty) {
        throw Exception('Anda belum Login.');
      }

      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/user-profil'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        UserProfile userProfile = UserProfile.fromJson(data['data']);
        return userProfile;
      } else if (response.statusCode == 401) {
        throw Exception('Token tidak valid. Silakan login ulang.');
      } else {
        throw Exception('Gagal memuat profil: ${response.body}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      throw Exception('Gagal memuat profil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  if (!authProvider.isCheckingLogin) {
                    Navigator.pushNamed(context, "/login");
                  } else {
                    Navigator.pushNamed(context, "/akun");
                  }
                },
                child: Row(
                  children: [
                    FutureBuilder<UserProfile?>(
                      future: userProfileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.grey,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          );
                        } else if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data == null) {
                          return const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person_outline,
                                color: Colors.white, size: 20),
                          );
                        } else {
                          final user = snapshot.data!;
                          return CircleAvatar(
                            radius: 14,
                            backgroundImage: _getProfileImage(user),
                            backgroundColor: Colors.grey,
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    FutureBuilder<UserProfile?>(
                      future: userProfileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Text(
                            'Error',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          );
                        } else if (snapshot.hasData && snapshot.data != null) {
                          final user = snapshot.data!;
                          return Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          );
                        } else {
                          return const Text(
                            'Login / Daftar',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  if (authProvider.isCheckingLogin) {
                    Navigator.pushNamed(context, "/notification");
                  } else {
                    Navigator.pushNamed(context, "/notification");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool _shouldShowDefaultIcon(AuthProvider authProvider) {
    return authProvider.userProfileImage == null ||
        authProvider.userProfileImage!.isEmpty;
  }

  ImageProvider? _getProfileImage(UserProfile user) {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (user.profileImage.isNotEmpty && user.profileImage != "") {
      try {
        // Use a reliable placeholder service or a local asset
        if (user.profileImage.contains('placeholder.com')) {
          // Return a local asset or a more reliable placeholder service
          return AssetImage('assets/images/dp.png');
        }
        return NetworkImage(user.profileImage);
      } catch (e) {
        print('Error loading network image: $e');
        return AssetImage('assets/images/dp.png');
      }
    }
    return null;
  }
}
