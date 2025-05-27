import 'package:carilaundry2/core/apiConstant.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  // Review related variables
  List<dynamic> _reviews = [];
  bool _isLoadingReviews = false;
  String? _reviewsErrorMessage;
  Map<String, dynamic>? _reviewStats;
  int _currentPage = 1;
  bool _hasMoreReviews = true;
  int? _selectedRatingFilter;
  int? _tokoId;

  @override
  void initState() {
    super.initState();
    fetchStoreData();
  }

  Future<void> fetchStoreData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokoId = prefs.getInt('id_toko') ?? 0;
      _tokoId = tokoId;

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
            _storeRating = data['data']['rating']?.toString() ?? 'N/A';
            _storeOrders = data['data']['orders']?.toString() ?? 'N/A';
            _storeLogo = data['data']['logo'];
            _isLoading = false;
          });

          // Fetch reviews after store data is loaded
          if (_tokoId != null && _tokoId! > 0) {
            fetchReviews();
          }
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

  Future<void> fetchReviews({bool loadMore = false}) async {
    if (_tokoId == null || _tokoId! <= 0) return;

    if (!loadMore) {
      setState(() {
        _isLoadingReviews = true;
        _reviewsErrorMessage = null;
        _currentPage = 1;
        _reviews.clear();
      });
    }

    try {
      String url =
          '${Apiconstant.BASE_URL}/toko/$_tokoId/ulasan?page=$_currentPage&per_page=5';

      if (_selectedRatingFilter != null) {
        url += '&rating=$_selectedRatingFilter';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Reviews URL: $url');
      print('Reviews Response Status: ${response.statusCode}');
      print('Reviews Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final reviewsData = data['data']['reviews'];
          final stats = data['data']['stats'];

          setState(() {
            if (loadMore) {
              _reviews.addAll(reviewsData['data']);
            } else {
              _reviews = reviewsData['data'];
            }
            _reviewStats = stats;
            _hasMoreReviews = reviewsData['next_page_url'] != null;
            _isLoadingReviews = false;
          });
        } else {
          setState(() {
            _reviewsErrorMessage = data['message'] ?? 'Gagal memuat ulasan';
            _isLoadingReviews = false;
          });
        }
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _reviewsErrorMessage = 'Gagal mengambil ulasan: $e';
        _isLoadingReviews = false;
      });
      print('Error fetching reviews: $e');
    }
  }

  void _loadMoreReviews() {
    if (_hasMoreReviews && !_isLoadingReviews) {
      _currentPage++;
      fetchReviews(loadMore: true);
    }
  }

  void _filterByRating(int? rating) {
    setState(() {
      _selectedRatingFilter = rating;
    });
    fetchReviews();
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
                      // Store Info Section
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
                                  value: _reviewStats != null
                                      ? (_reviewStats!['average_rating']
                                              ?.toString() ??
                                          'N/A')
                                      : (_storeRating ?? 'N/A'),
                                  icon: Icons.star,
                                ),
                                _buildInfoCard(
                                  title: "Total Ulasan",
                                  value: _reviewStats != null
                                      ? (_reviewStats!['total_reviews']
                                              ?.toString() ??
                                          '0')
                                      : '0',
                                  icon: Icons.rate_review,
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

                      const SizedBox(height: 24),

                      // Reviews Section
                      _buildReviewsSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviews Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF006A55),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.rate_review, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Ulasan Pelanggan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_reviewStats != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _reviewStats!['average_rating']?.toString() ?? '0',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Rating Filter
          if (_reviewStats != null &&
              _reviewStats!['rating_distribution'] != null)
            _buildRatingFilter(),

          // Reviews Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildReviewsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter berdasarkan rating:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', null),
                const SizedBox(width: 8),
                for (int i = 5; i >= 1; i--)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip('$i ⭐', i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int? rating) {
    final isSelected = _selectedRatingFilter == rating;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _filterByRating(rating),
      selectedColor: const Color(0xFF006A55).withOpacity(0.2),
      checkmarkColor: const Color(0xFF006A55),
    );
  }

  Widget _buildReviewsContent() {
    if (_isLoadingReviews && _reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_reviewsErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _reviewsErrorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchReviews,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.rate_review_outlined,
                  size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Belum ada ulasan untuk toko ini',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _reviews.length,
          separatorBuilder: (context, index) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final review = _reviews[index];
            return _buildReviewItem(review);
          },
        ),
        if (_hasMoreReviews) ...[
          const SizedBox(height: 16),
          Center(
            child: _isLoadingReviews
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _loadMoreReviews,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006A55),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Muat Lebih Banyak'),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final rating = review['rating'] ?? 0;
    final reviewText = review['review'] ?? '';
    final userName = review['user']?['name'] ?? 'Pengguna';
    final createdAt = review['created_at'] ?? '';
    // Parse date
    DateTime? reviewDate;
    try {
      reviewDate = DateTime.parse(createdAt);
    } catch (e) {
      reviewDate = null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF006A55),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (reviewDate != null)
                      Text(
                        '${reviewDate.day}/${reviewDate.month}/${reviewDate.year}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                  ],
                ),
              ),
              // Rating stars
              Row(
                mainAxisSize: MainAxisSize.min,
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

          if (reviewText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              reviewText,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
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
