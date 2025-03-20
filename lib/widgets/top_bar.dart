import 'package:flutter/material.dart';

class TopBarWidget extends StatefulWidget {
  final bool isLoggedIn; // Status login
  final String? userName; // Nama pengguna (jika sudah login)
  final String? userProfileImage; // Gambar profil pengguna (jika sudah login)

  const TopBarWidget({
    Key? key,
    this.isLoggedIn = false,
    this.userName,
    this.userProfileImage,
  }) : super(key: key);

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Login/Daftar or Username Button
          InkWell(
            onTap: () {
              if (!widget.isLoggedIn) {
                Navigator.pushNamed(context, "/login");
              } else {
                // Navigate to profile page when profile is tapped
                Navigator.pushNamed(context, "/profile").then((_) {
                  // Refresh data when returning from profile page (optional)
                  if (mounted) {
                    setState(() {});
                  }
                });
              }
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.grey,
                    backgroundImage: _getProfileImageProvider(),
                    child: (!widget.isLoggedIn || _shouldShowDefaultIcon())
                        ? Icon(Icons.person_outline,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isLoggedIn
                      ? widget.userName ?? 'name' // Nama jika login
                      : 'Login / Daftar', // Default jika belum login
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // Helper method to determine if we should show the default icon
  bool _shouldShowDefaultIcon() {
    return widget.userProfileImage == null ||
        widget.userProfileImage!.isEmpty ||
        widget.userProfileImage == "null";
  }

  // Helper method to get the profile image provider
  ImageProvider? _getProfileImageProvider() {
    if (widget.isLoggedIn &&
        widget.userProfileImage != null &&
        widget.userProfileImage!.isNotEmpty &&
        widget.userProfileImage != "null") {
      try {
        print('Using profile image URL: ${widget.userProfileImage}');
        return NetworkImage(widget.userProfileImage!);
      } catch (e) {
        print('Error creating NetworkImage: $e');
        return null;
      }
    }
    return null;
  }
}
