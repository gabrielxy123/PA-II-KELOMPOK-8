import 'package:carilaundry2/core/apiConstant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokoUserDetailPage extends StatefulWidget { 
  @override
  _TokoUserDetailPageState createState() => _TokoUserDetailPageState();
}

class _TokoUserDetailPageState extends State<TokoUserDetailPage> {
  List<Map<String, dynamic>> _products = [];
  String? _storeName;
  String? _storeLogo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final tokoId = prefs.getInt('id_toko') ?? 0;

      // Fetch store data and products in parallel
      final storeResponse = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/detail-toko-user/$tokoId'),
      );

      //Untuk memunculkan produk berdasarkan toko
      final productsResponse = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/produks-user/$tokoId'),
      );

      if (storeResponse.statusCode == 200) {
        final storeData = json.decode(storeResponse.body);
        if (storeData['success'] == true) {
          setState(() {
            _storeName = storeData['data']['nama']?.toString();
            _storeLogo = storeData['data']['logo']?.toString();
          });
        }
      }

      if (productsResponse.statusCode == 200) {
        final productsData = json.decode(productsResponse.body);
        if (productsData['data'] != null && productsData['data'] is List) {
          setState(() {
            _products = List<Map<String, dynamic>>.from(productsData['data']);
          });
        } else {
          setState(() {
            _products = [];
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _storeName ?? 'Toko Laundry',
          style: TextStyle(fontSize: 15),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 15),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            Navigator.pushReplacementNamed(
                                context, "/toko-profile");
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.all(20.0),
                              child: _buildLogo(_storeLogo),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _storeName ?? 'Nama Toko',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    color: Colors.yellow, size: 18),
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
                          'Produk laundry',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Divider(
                          color: Colors.grey,
                          thickness: 1,
                          indent: 15,
                          endIndent: 15,
                        ),
                        SizedBox(height: 25),
                        GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          children: _products
                              .map((service) => _buildServiceItem(
                                    service['nama'],
                                    service['logo'] ?? '',
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, "/order-menu");
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
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      'Pesan Sekarang',
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
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.local_laundry_service,
                    size: 40, color: Colors.grey);
              },
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
            return _defaultLogo();
          },
        ),
      );
    } else {
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
        Icons.local_laundry_service_rounded,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}
