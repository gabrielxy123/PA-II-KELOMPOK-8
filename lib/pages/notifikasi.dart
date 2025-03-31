import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.white, // Teks putih
            fontSize: 18, // Ukuran font
            fontWeight: FontWeight.bold, // Ketebalan font
          ),
        ),
        backgroundColor: const Color(0xFF006A55), // Warna hijau app bar
        iconTheme: IconThemeData(
            color: Colors.white), // Warna ikon putih (back button)
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: [
          NotificationItem(
            title: 'Pesanan laundry anda sudah siap diambil!',
            message:
                'Laundry Anda telah selesai dan siap diambil di Agian Laundry.',
            timestamp: '30 Menit Lalu',
            icon: Icons.check_circle,
            iconColor: Colors.green, // Original icon color
          ),
          NotificationItem(
            title: 'Pesanan laundry Anda sedang dicuci.',
            message:
                'Kami sedang mencuci pesanan Anda. Mohon tunggu sebentar ya',
            timestamp: '40 Menit Lalu',
            icon: Icons.local_laundry_service,
            iconColor: Colors.blue, // Original icon color
          ),
          NotificationItem(
            title: 'Promo Kilat! Diskon 20% Hari Ini!',
            message:
                'Yuk, nikmati diskon 20% untuk layanan cuci ekspres khusus hari ini.',
            timestamp: '1 Jam Lalu',
            icon: Icons.local_offer,
            iconColor: Colors.yellow, // Original icon color
          ),
          NotificationItem(
            title: 'Pengingat! Ambil pesanan laundry anda ....',
            message:
                'Jangan lupa ambil pesanan laundry Anda hari ini. Kami siap melayani!',
            timestamp: '2 Jam Lalu',
            icon: Icons.alarm,
            iconColor: Colors.red, // Original icon color
          ),
        ],
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String timestamp;
  final IconData icon;
  final Color iconColor;

  const NotificationItem({
    Key? key,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: Color(0xFFDCFCE7), // Light green background (#DCFCE7)
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(0xFFDCFCE7), // Warna background
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      const Color.fromARGB(255, 208, 204, 204), // Warna border
                  width: 1.0, // Ketebalan border
                ),
              ),
              child: Icon(
                // Widget anak (icon)
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black, // Black text for better contrast
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[800], // Dark gray text
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
