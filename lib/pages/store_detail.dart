import 'package:carilaundry2/models/layanan.dart';
import 'package:carilaundry2/models/produk.dart'; // Make sure this path is correct
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:intl/intl.dart'; // Import for NumberFormat

class TokoUserDetailPage extends StatefulWidget {
  @override
  _TokoUserDetailPageState createState() => _TokoUserDetailPageState();
}

class _TokoUserDetailPageState extends State<TokoUserDetailPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _layanans = [];
  String? _storeName;
  String? _storeLogo;
  bool _isLoading = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStoreData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final tokoId = prefs.getInt('id_toko') ?? 0;

      // --- Store Data ---
      final storeResponse = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/detail-toko-user/$tokoId'),
      );
      if (storeResponse.statusCode == 200) {
        final storeData = json.decode(storeResponse.body);
        if (storeData['data'] != null) {
          // Removed success check
          setState(() {
            _storeName = storeData['data']['nama'];
            _storeLogo = storeData['data']['logo'];
          });
        }
      } else {
        print('Failed to load store data: ${storeResponse.statusCode}');
        print('Store Response Body: ${storeResponse.body}');
      }

      // --- Products Data ---
      print('Fetching products...');
      final productsResponse = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/produks-user/$tokoId'),
      );
      // print('Products Response Status: ${productsResponse.statusCode}');
      // print('Products Response Body: ${productsResponse.body}');

      if (productsResponse.statusCode == 200) {
        final productsData = json.decode(productsResponse.body);
        // print('Parsed Products JSON: $productsData');

        if (productsData['data'] != null) {
          // Removed success check
          final rawProductList = productsData['data'];
          // print('Raw products list from API: $rawProductList');
          if (rawProductList is List) {
            setState(() {
              _products = rawProductList.cast<Map<String, dynamic>>();
              // print('Updated _products state: $_products');
            });
          } else {
            // print('ERROR: productsData[\'data\'] is not a List');
            setState(() {
              _products = [];
            });
          }
        } else {
          // print('Products data is null in response');
          setState(() {
            _products = [];
          });
        }
      } else {
        // print('Failed to load products: ${productsResponse.statusCode}');
        setState(() {
          _products = [];
        });
      }

      // --- Layanan Data ---
      // print('Fetching layanan...');
      final layananResponse = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/layanan-user/$tokoId'),
      );
      // print('Layanan Response Status: ${layananResponse.statusCode}');
      // print('Layanan Response Body: ${layananResponse.body}');

      if (layananResponse.statusCode == 200) {
        final layananData = json.decode(layananResponse.body);
        // print('Parsed Layanan JSON: $layananData');

        if (layananData['data'] != null) {
          // Removed success check
          final rawLayananList = layananData['data'];
          // print('Raw layanan list from API: $rawLayananList');
          if (rawLayananList is List) {
            setState(() {
              _layanans = rawLayananList.cast<Map<String, dynamic>>();
              // print('Updated _layanans state: $_layanans');
            });
          } else {
            // print('ERROR: layananData[\'data\'] is not a List');
            setState(() {
              _layanans = [];
            });
          }
        } else {
          // print('Layanan data is null in response');
          setState(() {
            _layanans = [];
          });
        }
      } else {
        // print('Failed to load layanan: ${layananResponse.statusCode}');
        setState(() {
          _layanans = [];
        });
      }
    } catch (e, s) {
      print('Error loading store data: $e');
      print('Stack trace: $s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _storeName ?? 'Toko Anda', // Display fetched store name or default
          style: TextStyle(fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 20), // Added refresh button
            onPressed: _isLoading ? null : _loadStoreData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: const Color(0xFF006A55),
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
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
                            color: Colors.white, // Background for the logo area
                            // padding: EdgeInsets.all(_storeLogo != null && _storeLogo!.isNotEmpty ? 0 : 8.0), // Padding only if default
                            child: _buildLogo(_storeLogo),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _storeName ?? 'Nama Toko Belum Diatur',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            // These are hardcoded, consider fetching them if available
                            Text(
                              'No. Telp 082232323234',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    color: Colors.yellow, size: 16),
                                Text(
                                  ' 4.8 (244)',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Jenis-jenis Layanan Toko',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF006A55),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF006A55),
                  tabs: [
                    Tab(text: 'Kategori Laundry'),
                    Tab(text: 'Layanan Tambahan'), // Changed text for clarity
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductGrid(),
                      _buildAdditionalProductGrid(),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/order-menu");
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
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
    );
  }

  Widget _buildProductGrid() {
    // // Debug print to verify data
    // print('Products data: $_products');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 16),
                  Text("Belum ada produk laundry."),
                ],
              ),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: _products.length, // +1 for add button
              itemBuilder: (context, index) {
                try {
                  final productMap = _products[index];
                  // print('Product $productIndex data: $productMap'); // Debug

                  final produk = Produk.fromJson(productMap);
                  return _buildProdukItem(produk, onTap: () {
                    // Handle product tap
                  });
                } catch (e) {
                  print('Error building product item $index: $e');
                  return _buildErrorItem();
                }
              },
            ),
    );
  }

// Helper widget for error cases
  Widget _buildErrorItem() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.error_outline, color: Colors.red),
      ),
    );
  }

  Widget _buildAdditionalProductGrid() {
    // print('Products data: $_layanans');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _layanans.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 16),
                  Text("Belum ada layanan tambahan laundry."),
                ],
              ),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: _layanans.length, // +1 for add button
              itemBuilder: (context, index) {
                try {
                  final layananMap = _layanans[index];
                  // print('Product $productIndex data: $productMap'); // Debug

                  final layanan = Layanan.fromJson(layananMap);
                  return _buildLayananItem(layanan, onTap: () {
                    // Handle product tap
                  });
                } catch (e) {
                  print('Error building product item $index: $e');
                  return _buildErrorItem();
                }
              },
            ),
    );
  }

  // Updated to take a Produk object
  Widget _buildProdukItem(Produk produk, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5), // A light grey background
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Make children stretch
          children: [
            Expanded(
              // To make the image/icon take available space
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: (produk.logoUrl != null && produk.logoUrl!.isNotEmpty)
                    ? Image.network(
                        produk.logoUrl!,
                        fit: BoxFit
                            .contain, // Use contain to see the whole image
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback icon if image fails to load
                          return Icon(Icons.broken_image_outlined,
                              size: 40, color: Colors.grey[600]);
                        },
                      )
                    // Default icon if no logoUrl
                    : Icon(Icons.inventory_2_outlined,
                        size: 40, color: Colors.grey[600]),
              ),
            ),
            // SizedBox(height: 4), // Reduced space
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                produk.nama,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 2.0, bottom: 6.0), // Adjusted padding
              child: Text(
                // Format harga with thousands separator
                'Rp ${NumberFormat('#,###', 'id_ID').format(produk.harga)}',
                style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF006A55), // Theme color for price
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            // SizedBox(height: 4), // Reduced space
          ],
        ),
      ),
    );
  }

  Widget _buildLayananItem(Layanan layanan, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5), // A light grey background
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Make children stretch
          children: [
            Expanded(
              // To make the image/icon take available space
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: (layanan.logoUrl != null && layanan.logoUrl!.isNotEmpty)
                    ? Image.network(
                        layanan.logoUrl!,
                        fit: BoxFit
                            .contain, // Use contain to see the whole image
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback icon if image fails to load
                          return Icon(Icons.broken_image_outlined,
                              size: 40, color: Colors.grey[600]);
                        },
                      )
                    // Default icon if no logoUrl
                    : Icon(Icons.inventory_2_outlined,
                        size: 40, color: Colors.grey[600]),
              ),
            ),
            // SizedBox(height: 4), // Reduced space
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Text(
                layanan.nama,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 2.0, bottom: 6.0), // Adjusted padding
              child: Text(
                // Format harga with thousands separator
                'Rp ${NumberFormat('#,###', 'id_ID').format(layanan.harga)}',
                style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF006A55), // Theme color for price
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            // SizedBox(height: 4), // Reduced space
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(String? logoUrl) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          logoUrl,
          height: 60,
          width: 60,
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
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200], // Slightly different color for default
        borderRadius: BorderRadius.circular(
            8.0), // Ensure this matches ClipRRect if image is present
      ),
      child: const Icon(
        Icons.local_laundry_service_rounded,
        size: 30,
        color: Color(0xFF006A55), // Theme color for icon
      ),
    );
  }
}
