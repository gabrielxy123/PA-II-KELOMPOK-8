import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carilaundry2/models/laundry.dart'; // Pastikan path ini sesuai

class TokoCardWidget extends StatelessWidget {
  final Laundry laundry;

  const TokoCardWidget({Key? key, required this.laundry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 195, 195, 195),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo
          Expanded(
            flex: 3,
            child: Center(
              child: Image.network(
                laundry.logo,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: 200,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.local_laundry_service),
                  );
                },
              ),
            ),
          ),
          // Title and Description
          Expanded(
            flex: 2,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    laundry.nama,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 7),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      laundry.deskripsi,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          ),
          // Price Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _saveLaundryIdAndNavigate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(156, 2, 103, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text(
                'Detail Laundry',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLaundryIdAndNavigate(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id_toko', laundry.id); // Simpan ID laundry

      // Navigasi ke halaman detail dengan membawa objek laundry
      Navigator.pushNamed(context, "/toko-detail", arguments: laundry);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan ID laundry: $e')),
      );
    }
  }
}
