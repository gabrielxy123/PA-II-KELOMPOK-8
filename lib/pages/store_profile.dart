import 'package:flutter/material.dart';
import 'package:carilaundry2/pages/store_detail.dart';

class StoreProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profil Toko - Laundry Agian",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF006A55),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
                border: Border.all(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  width: 1,
                ),
              ),
              child: Image.asset(
                "assets/images/agian.png",
                height: 80,
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              "Laundry Agian",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE4EEEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    '"Bersih, Wangi, dan Rapi! ✨"\n\n'
                    'Kami hadir untuk memberikan layanan laundry terbaik '
                    'dengan hasil yang bersih, harum, dan rapi. Dari cuci biasa '
                    'hingga setrika, kami siap membantu Anda menghemat waktu dan tenaga. '
                    'Dengan layanan cepat dan harga terjangkau, pakaian Anda akan kembali '
                    'segar seperti baru!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoCard(
                        title: "Rating Toko",
                        value: "4.8 / 5.0",
                        icon: Icons.star,
                      ),
                      _buildInfoCard(
                        title: "Jumlah Pesanan",
                        value: "200 +",
                        icon: Icons.list,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                      "Alamat", "Jl. Balige - Tarutung No. 200"),
                  _buildDetailSection("Hari Operasional", "Senin - Jumat"),
                  _buildDetailSection("Jam Operasional", "08.00 - 17.00"),
                  const SizedBox(height: 16),
                  _buildDetailSection("Kontak", ""),
                  _buildContactRow("Whatsapp", "081234567890", Icons.phone_android_rounded),
                  _buildContactRow("Facebook", "Laundry Agian", Icons.facebook),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required String value, required IconData icon}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF006A55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title : ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(content)),
        ],
      ),
    );
  }

  Widget _buildContactRow(String platform, String contact, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green[800]),
          const SizedBox(width: 8),
          Text(platform, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(contact),
        ],
      ),
    );
  }
}
