import 'package:carilaundry2/core/apiConstant.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // Untuk decode JSON
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Untuk request HTTP

class TokoProfileUserPage extends StatefulWidget {
  @override
  _TokoProfileUserPageState createState() => _TokoProfileUserPageState();
}

class _TokoProfileUserPageState extends State<TokoProfileUserPage> {
  String? _storeName;
  String? _storeDescription;
  String? _storeAddress;
  String? _storeOperationDays;
  String? _storeOperationHours;
  String? _storeContact;
  String? _storeFacebook;
  String? _storeRating;
  String? _storeOrders;
  String? _kecamatan;
  String? _kabupaten;
  String? _storeLogo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchStoreData();
  }

  Future<void> fetchStoreData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('auth_token') ?? '';
      final tokoId = prefs.getInt('id_toko') ?? 0;
      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/detail-toko-user/$tokoId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _storeName = data['data']['nama'];
            _storeDescription =
                data['data']['deskripsi'] ?? 'Deskripsi tidak tersedia';
            _storeAddress = data['data']['jalan'] ?? 'Alamat tidak tersedia';
            _kecamatan = data['data']['kecamatan'] ?? 'Kecamatan tidak disertakan';
            _kabupaten = data['data']['kabupaten'] ?? 'Kabupaten tidak disertakan';
            _storeOperationDays =
                data['data']['waktuBuka'] ?? 'Waktu buka tidak tersedia';
            _storeOperationHours =
                data['data']['waktuTutup'] ?? 'Waktu tutup tidak tersedia';
            _storeContact = data['data']['noTelp'] ?? 'Kontak tidak tersedia';
            _storeFacebook =
                data['data']['facebook'] ?? 'Facebook tidak tersedia';
            _storeRating = data['data']['rating']?.toString() ?? 'N/A';
            _storeOrders = data['data']['orders']?.toString() ?? 'N/A';
            _storeLogo = data['data']['logo'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengambil data toko: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLoading ? 'Loading...' : _storeName ?? 'Toko Tidak Ditemukan',
          style: const TextStyle(fontSize: 16, color: Colors.white),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
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
                        child: _buildLogo(_storeLogo),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _storeName ?? 'Nama Tidak Tersedia',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
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
                            Text(
                              _storeDescription ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildInfoCard(
                                  title: "Rating Toko",
                                  value: _storeRating ?? 'N/A',
                                  icon: Icons.star,
                                ),
                                _buildInfoCard(
                                  title: "Jumlah Pesanan",
                                  value: _storeOrders ?? 'N/A',
                                  icon: Icons.list,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildDetailSection("Alamat", _storeAddress ?? ''),
                            _buildDetailSection("Kecamatan", _kecamatan ?? ''),
                            _buildDetailSection("Kabupaten", _kabupaten ?? ''),
                            _buildDetailSection(
                                "Waktu Buka", _storeOperationDays ?? ''),
                            _buildDetailSection(
                                "Waktu Tutup", _storeOperationHours ?? ''),
                            const SizedBox(height: 16),
                            _buildDetailSection("Kontak", ""),
                            _buildContactRow("Whatsapp", _storeContact ?? 'N/A',
                                Icons.phone_android_rounded),
                            _buildContactRow("Facebook",
                                _storeFacebook ?? 'N/A', Icons.facebook),
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

  Widget _buildLogo(String? logoUrl) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          logoUrl,
          height: 80,
          width: 80,
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
      height: 80,
      width: 80,
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
