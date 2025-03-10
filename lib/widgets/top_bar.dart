import 'package:flutter/material.dart';


class TopBarWidget extends StatefulWidget {
  final bool isLoggedIn; // Status login
  final String? userName; // Nama pengguna (jika sudah login)

  const TopBarWidget({
    Key? key,
    this.isLoggedIn = false,
    this.userName,
  }) : super(key: key);

  @override
  State<TopBarWidget> createState() => _TopBarWidgetState();
}

class _TopBarWidgetState extends State<TopBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children:[
          // Login/Daftar or Username Button
          InkWell(
            onTap: () {
              if (!widget.isLoggedIn) {
                Navigator.pushNamed(context, "/login");
              } else {
                // Optional: Tambahkan aksi ketika pengguna yang login mengetuk nama
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
                    child: Icon(Icons.person_outline, color: Colors.white, size: 20),
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
}