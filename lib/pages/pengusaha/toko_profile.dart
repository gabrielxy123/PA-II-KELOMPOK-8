import 'package:carilaundry2/core/apiConstant.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TokoProfilePage extends StatefulWidget {
  @override
  _TokoProfilePageState createState() => _TokoProfilePageState();
}

class _TokoProfilePageState extends State<TokoProfilePage> {
  String? _storeName;
  String? _storeDescription;
  String? _storeAddress;
  String? _storeOperationDays;
  String? _storeOperationHours;
  String? _storeContact;
  String? _storeFacebook;
  String? _storeLogo;
  String? _kecamatan;
  String? _kabupaten;
  bool _isLoading = true;
  String? _errorMessage;

  // Review stats variables
  double? _averageRating;
  int? _totalReviews;
  bool _reviewStatsLoaded = false;

  // Recent reviews variables
  List<Map<String, dynamic>> _recentReviews = [];
  bool _recentReviewsLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchStoreData();
  }

  Future<void> fetchStoreData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      // Fetch store data
      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/toko-saya'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _storeName = data['data']['nama'];
            _storeDescription =
                data['data']['deskripsi'] ?? 'Deskripsi tidak tersedia';
            _storeAddress = data['data']['jalan'] ?? 'Alamat tidak tersedia';
            _kecamatan =
                data['data']['kecamatan'] ?? 'Kecamatan tidak disertakan';
            _kabupaten =
                data['data']['kabupaten'] ?? 'Kabupaten tidak disertakan';
            _storeOperationDays =
                data['data']['waktuBuka'] ?? 'Waktu buka tidak tersedia';
            _storeOperationHours =
                data['data']['waktuTutup'] ?? 'Waktu tutup tidak tersedia';
            _storeContact = data['data']['noTelp'] ?? 'Kontak tidak tersedia';
            _storeFacebook =
                data['data']['facebook'] ?? 'Facebook tidak tersedia';
            _storeLogo = data['data']['logo'];
            _isLoading = false;
          });

          // Fetch review stats and recent reviews after store data is loaded
          await _fetchReviewStats(token);
          await _fetchRecentReviews(token);
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

  Future<void> _fetchReviewStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${Apiconstant.BASE_URL}/pengusaha/toko-saya/ulasan/statistik'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
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

  Future<void> _fetchRecentReviews(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${Apiconstant.BASE_URL}/pengusaha/toko-saya/ulasan?per_page=3'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data']['reviews'] != null) {
          if (mounted) {
            setState(() {
              _recentReviews =
                  List<Map<String, dynamic>>.from(data['data']['reviews']);
              _recentReviewsLoaded = true;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading recent reviews: $e');
      if (mounted) {
        setState(() {
          _recentReviewsLoaded = true;
        });
      }
    }
  }

  Widget _buildRatingInfoCard() {
    if (!_reviewStatsLoaded) {
      return _buildInfoCard(
        title: "Rating Toko",
        value: "...",
        icon: Icons.star,
      );
    }

    if (_totalReviews == null || _totalReviews! == 0) {
      return _buildInfoCard(
        title: "Rating Toko",
        value: "Belum ada",
        icon: Icons.star_border,
      );
    }

    return _buildInfoCard(
      title: "Rating Toko",
      value: "${_averageRating?.toStringAsFixed(1) ?? '0.0'}",
      icon: Icons.star,
    );
  }

  Widget _buildTotalReviewsCard() {
    if (!_reviewStatsLoaded) {
      return _buildInfoCard(
        title: "Total Ulasan",
        value: "...",
        icon: Icons.rate_review,
      );
    }

    return _buildInfoCard(
      title: "Total Ulasan",
      value: "${_totalReviews ?? 0}",
      icon: Icons.rate_review,
    );
  }

  Widget _buildRecentReviewsSection() {
    if (!_recentReviewsLoaded) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recentReviews.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              'Belum ada ulasan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Ulasan dari pelanggan akan muncul di sini',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ulasan Terbaru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_totalReviews != null && _totalReviews! > 3)
              TextButton(
                onPressed: () {
                  // Navigate to full reviews page
                  // Navigator.pushNamed(context, '/ulasan-lengkap');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Fitur halaman ulasan lengkap akan segera hadir')),
                  );
                },
                child: Text('Lihat Semua'),
              ),
          ],
        ),
        SizedBox(height: 8),
        ...(_recentReviews
            .take(3)
            .map((review) => _buildReviewItem(review))
            .toList()),
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final rating = review['rating'] ?? 0;
    final comment = review['review'] ?? '';
    final userName = review['user']?['name'] ?? 'Pengguna';
    final createdAt = review['created_at'] ?? '';
    final kodeTransaksi = review['transaksi']?['kode_transaksi'] ?? '';

    // Parse date
    String formattedDate = '';
    try {
      final date = DateTime.parse(createdAt);
      formattedDate = '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      formattedDate = 'Tanggal tidak valid';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF006A55),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              comment,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (kodeTransaksi.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Transaksi: $kodeTransaksi',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
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
                                _buildRatingInfoCard(),
                                _buildTotalReviewsCard(), // CHANGED: dari Jumlah Pesanan ke Total Ulasan
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
                      const SizedBox(height: 20),
                      // NEW: Recent Reviews Section
                      _buildRecentReviewsSection(),
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
