import 'package:carilaundry2/core/apiConstant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokoDetailPage extends StatefulWidget {
  @override
  _TokoDetailPageState createState() => _TokoDetailPageState();
}

class _TokoDetailPageState extends State<TokoDetailPage> {
  late Future<List<Map<String, dynamic>>> _laundryServicesFuture;
  String? _storeName;
  String? _storeLogo;

  @override
  void initState() {
    super.initState();
    _laundryServicesFuture = fetchLaundryServices();
  }

  Future<List<Map<String, dynamic>>> fetchLaundryServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final response = await http.get(
        Uri.parse(
            '${Apiconstant.BASE_URL}/toko-saya'), // Ganti dengan URL API Anda
        headers: {
          'Authorization': 'Bearer $token', // Ganti dengan token otentikasi
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _storeName = data['data']['nama'];
            _storeLogo = data['data']['logo'];
          });

          return List<Map<String, dynamic>>.from(data['toko']);
        } else {
          throw Exception('Failed to load services');
        }
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _storeName != null
              ? '$_storeName'
              : 'Toko Laundry - Loading...',
          style: TextStyle(fontSize: 15),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 15),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, size: 20),
            onPressed: () {
              // Aksi untuk edit toko
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF006A55),
              padding: EdgeInsets.all(35.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigasi ke halaman profil toko
                      Navigator.pushReplacementNamed(
                          context, "/profile-toko-saya");
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(20.0),
                        child: _buildLogo(_storeLogo)
                        ),
                      ),
                    ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _storeName != null ? '$_storeName' : 'Loading...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: 18),
                          Text(
                            ' 4.8 (244)',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        '300+ Pesanan Selesai',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jenis-jenis layanan laundry',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  SizedBox(height: 25),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _laundryServicesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                'Terjadi kesalahan saat memuat layanan: ${snapshot.error}'));
                      } else {
                        final services = snapshot.data!;
                        return GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          children: services
                              .map((service) => _buildServiceItem(
                                    service['nama'],
                                    service['logo'],
                                  ))
                              .toList(),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Aksi untuk menambah layanan
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006A55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          'Tambah Jenis Layanan',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
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

  Widget _buildServiceItem(String title, String imagePath) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFE4EEEC),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color:
                    const Color.fromARGB(255, 157, 155, 155).withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildLogo(String? logoUrl) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          logoUrl,
          height: 75,
          width: 75,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Jika gagal memuat gambar
            return _defaultLogo();
          },
        ),
      );
    } else {
      // Jika URL kosong atau null
      return _defaultLogo();
    }
  }

  Widget _defaultLogo() {
    return Container(
      height: 75,
      width: 75,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Icon(
        Icons.local_laundry_service,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}
