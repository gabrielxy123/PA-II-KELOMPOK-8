import 'package:carilaundry2/models/layanan.dart';
import 'package:carilaundry2/models/produk.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:intl/intl.dart';

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
  String? _storeTelp;
  bool _isLoading = true;

  // Tambahkan variabel untuk review stats
  double? _averageRating;
  int? _totalReviews;
  bool _reviewStatsLoaded = false;

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
          setState(() {
            _storeName = storeData['data']['nama'];
            _storeTelp = storeData['data']['noTelp'];
            _storeLogo = storeData['data']['logo'];
          });
        }
      } else {
        print('Failed to load store data: ${storeResponse.statusCode}');
        print('Store Response Body: ${storeResponse.body}');
      }

      // --- Review Stats Data --- (TAMBAHAN BARU)
      await _fetchReviewStats(tokoId);

      // --- Products Data ---
      print('Fetching products...');
      final productsResponse = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/produks-user/$tokoId'),
      );

      if (productsResponse.statusCode == 200) {
        final productsData = json.decode(productsResponse.body);

        if (productsData['data'] != null) {
          final rawProductList = productsData['data'];
          if (rawProductList is List) {
            setState(() {
              _products = rawProductList.cast<Map<String, dynamic>>();
            });
          } else {
            setState(() {
              _products = [];
            });
          }
        } else {
          setState(() {
            _products = [];
          });
        }
      } else {
        setState(() {
          _products = [];
        });
      }

      // --- Layanan Data ---
      final layananResponse = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/layanan-user/$tokoId'),
      );

      if (layananResponse.statusCode == 200) {
        final layananData = json.decode(layananResponse.body);

        if (layananData['data'] != null) {
          final rawLayananList = layananData['data'];
          if (rawLayananList is List) {
            setState(() {
              _layanans = rawLayananList.cast<Map<String, dynamic>>();
            });
          } else {
            setState(() {
              _layanans = [];
            });
          }
        } else {
          setState(() {
            _layanans = [];
          });
        }
      } else {
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

  // METHOD BARU untuk fetch review stats
  Future<void> _fetchReviewStats(int tokoId) async {
    if (tokoId <= 0) return;

    try {
      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/toko/$tokoId/ulasan?per_page=1'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data']['stats'] != null) {
          final stats = data['data']['stats'];
          if (mounted) {
            setState(() {
              _averageRating = (stats['average_rating'] ?? 0.0).toDouble();
              _totalReviews = stats['total_reviews'] ?? 0;
              _reviewStatsLoaded = true;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading review stats: $e');
      if (mounted) {
        setState(() {
          _reviewStatsLoaded = true;
        });
      }
    }
  }

  // METHOD BARU untuk build rating display
  Widget _buildRatingDisplay() {
    if (!_reviewStatsLoaded) {
      // Loading state
      return Row(
        children: [
          Icon(Icons.star, color: Colors.yellow, size: 16),
          SizedBox(width: 4),
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      );
    }

    if (_totalReviews == null || _totalReviews! == 0) {
      // No reviews state
      return Row(
        children: [
          Icon(Icons.star_border, color: Colors.grey[300], size: 16),
          Text(
            ' Belum ada ulasan',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      );
    }

    // Has reviews state
    return Row(
      children: [
        Icon(Icons.star, color: Colors.yellow, size: 16),
        Text(
          ' ${_averageRating?.toStringAsFixed(1) ?? '0.0'} ($_totalReviews)',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _storeName ?? 'Toko Anda',
          style: TextStyle(fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 20),
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
                          Navigator.pushNamed(
                              context, "/toko-profile");
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            color: Colors.white,
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
                            Text(
                              _storeTelp ?? 'No telepon tidak tersedia',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            // GANTI Row yang hardcoded dengan method baru
                            _buildRatingDisplay(),
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
                    Tab(text: 'Layanan Tambahan'),
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

  // SEMUA METHOD LAINNYA TETAP SAMA, TIDAK ADA PERUBAHAN
  Widget _buildProductGrid() {
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
              itemCount: _products.length,
              itemBuilder: (context, index) {
                try {
                  final productMap = _products[index];
                  final produk = Produk.fromJson(productMap);
                  return _buildProdukItem(produk, onTap: () {});
                } catch (e) {
                  print('Error building product item $index: $e');
                  return _buildErrorItem();
                }
              },
            ),
    );
  }

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
              itemCount: _layanans.length,
              itemBuilder: (context, index) {
                try {
                  final layananMap = _layanans[index];
                  final layanan = Layanan.fromJson(layananMap);
                  return _buildLayananItem(layanan, onTap: () {});
                } catch (e) {
                  print('Error building product item $index: $e');
                  return _buildErrorItem();
                }
              },
            ),
    );
  }

  Widget _buildProdukItem(Produk produk, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: (produk.logoUrl != null && produk.logoUrl!.isNotEmpty)
                    ? Image.network(
                        produk.logoUrl!,
                        fit: BoxFit.contain,
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
                          return Icon(Icons.broken_image_outlined,
                              size: 40, color: Colors.grey[600]);
                        },
                      )
                    : Icon(Icons.inventory_2_outlined,
                        size: 40, color: Colors.grey[600]),
              ),
            ),
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
              padding: const EdgeInsets.only(top: 2.0, bottom: 6.0),
              child: Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format(produk.harga)}',
                style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF006A55),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
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
          color: const Color(0xFFF5F5F5),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: (layanan.logoUrl != null && layanan.logoUrl!.isNotEmpty)
                    ? Image.network(
                        layanan.logoUrl!,
                        fit: BoxFit.contain,
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
                          return Icon(Icons.broken_image_outlined,
                              size: 40, color: Colors.grey[600]);
                        },
                      )
                    : Icon(Icons.inventory_2_outlined,
                        size: 40, color: Colors.grey[600]),
              ),
            ),
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
              padding: const EdgeInsets.only(top: 2.0, bottom: 6.0),
              child: Text(
                'Rp ${NumberFormat('#,###', 'id_ID').format(layanan.harga)}',
                style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF006A55),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
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
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Icon(
        Icons.local_laundry_service_rounded,
        size: 30,
        color: Color(0xFF006A55),
      ),
    );
  }
}
