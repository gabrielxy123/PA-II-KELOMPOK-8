import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carilaundry2/AuthProvider/auth_provider.dart'; // Pastikan path benar
import 'package:carilaundry2/pages/notifikasi.dart';
import 'package:carilaundry2/pages/not_logged.dart';

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
  @override
  void initState() {
    super.initState();
    // Debug print to check if profile image URL is being passed correctly
    print('TopBarWidget - isLoggedIn: ${widget.isLoggedIn}');
    print('TopBarWidget - userProfileImage: ${widget.userProfileImage}');
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
                  if (!authProvider.isLoggedIn) {
                    Navigator.pushNamed(context, "/login");
                  } else {
                    Navigator.pushNamed(context, "/user-profil");
                  }
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey,
                      backgroundImage: _getProfileImage(authProvider),
                      child: (!authProvider.isLoggedIn ||
                              _shouldShowDefaultIcon(authProvider))
                          ? const Icon(Icons.person_outline,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      authProvider.isLoggedIn
                          ? authProvider.username ?? 'name'
                          : 'Login / Daftar',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  if (authProvider.isLoggedIn) {
                    Navigator.pushNamed(context, "/notifications");
                  } else {
                    Navigator.pushNamed(context, "/not-logged");
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

  ImageProvider? _getProfileImage(AuthProvider authProvider) {
    if (authProvider.userProfileImage != null &&
        authProvider.userProfileImage!.isNotEmpty) {
      try {
        return NetworkImage(authProvider.userProfileImage!);
      } catch (e) {
        return const AssetImage('assets/images/dp.png');
      }
    }
    return null;
  }
}
