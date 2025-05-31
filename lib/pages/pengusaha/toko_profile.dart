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
  // Existing variables
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
  String? _provinsi;
  bool _isLoading = true;
  String? _errorMessage;

  // Edit mode variables
  bool _isEditMode = false;
  bool _isSaving = false;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _waktuBukaController;
  late TextEditingController _waktuTutupController;

  // Address dropdown variables
  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> regencies = [];
  List<Map<String, dynamic>> districts = [];
  
  String? selectedProvinceId;
  String? selectedRegencyId;
  String? selectedDistrictId;
  
  String? selectedProvinceName;
  String? selectedRegencyName;
  String? selectedDistrictName;
  
  bool isLoadingProvinces = false;
  bool isLoadingRegencies = false;
  bool isLoadingDistricts = false;

  // Review stats variables (existing)
  double? _averageRating;
  int? _totalReviews;
  bool _reviewStatsLoaded = false;
  List<Map<String, dynamic>> _recentReviews = [];
  bool _recentReviewsLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    fetchStoreData();
    _loadProvinces();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _contactController = TextEditingController();
    _waktuBukaController = TextEditingController();
    _waktuTutupController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _waktuBukaController.dispose();
    _waktuTutupController.dispose();
    super.dispose();
  }

  void _populateControllers() {
    _nameController.text = _storeName ?? '';
    _descriptionController.text = _storeDescription ?? '';
    _addressController.text = _storeAddress ?? '';
    _contactController.text = _storeContact ?? '';
    _waktuBukaController.text = _storeOperationDays ?? '';
    _waktuTutupController.text = _storeOperationHours ?? '';
    
    // Set selected address values
    selectedProvinceName = _provinsi;
    selectedRegencyName = _kabupaten;
    selectedDistrictName = _kecamatan;
  }

  // Address API methods
  Future<void> _loadProvinces() async {
    setState(() => isLoadingProvinces = true);
    try {
      final response = await http.get(
        Uri.parse('https://emsifa.github.io/api-wilayah-indonesia/api/provinces.json')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          provinces = data.map((province) => {
            'id': province['id'].toString(),
            'name': province['name']
          }).toList();
        });
        
        // Find and set current province if exists
        if (_provinsi != null) {
          final currentProvince = provinces.firstWhere(
            (province) => province['name'] == _provinsi,
            orElse: () => {},
          );
          if (currentProvince.isNotEmpty) {
            selectedProvinceId = currentProvince['id'];
            _loadRegencies(selectedProvinceId!);
          }
        }
      }
    } catch (e) {
      print('Error loading provinces: $e');
    } finally {
      setState(() => isLoadingProvinces = false);
    }
  }

  Future<void> _loadRegencies(String provinceId) async {
    setState(() {
      if (selectedProvinceId != provinceId) {
        selectedRegencyId = null;
        selectedRegencyName = null;
        selectedDistrictId = null;
        selectedDistrictName = null;
      }
      regencies = [];
      districts = [];
      isLoadingRegencies = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://emsifa.github.io/api-wilayah-indonesia/api/regencies/$provinceId.json')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          regencies = data.map((regency) => {
            'id': regency['id'].toString(),
            'name': regency['name']
          }).toList();
        });
        
        // Find and set current regency if exists
        if (_kabupaten != null && selectedRegencyId == null) {
          final currentRegency = regencies.firstWhere(
            (regency) => regency['name'] == _kabupaten,
            orElse: () => {},
          );
          if (currentRegency.isNotEmpty) {
            selectedRegencyId = currentRegency['id'];
            _loadDistricts(selectedRegencyId!);
          }
        }
      }
    } catch (e) {
      print('Error loading regencies: $e');
    } finally {
      setState(() => isLoadingRegencies = false);
    }
  }

  Future<void> _loadDistricts(String regencyId) async {
    setState(() {
      if (selectedRegencyId != regencyId) {
        selectedDistrictId = null;
        selectedDistrictName = null;
      }
      districts = [];
      isLoadingDistricts = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://emsifa.github.io/api-wilayah-indonesia/api/districts/$regencyId.json')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          districts = data.map((district) => {
            'id': district['id'].toString(),
            'name': district['name']
          }).toList();
        });
        
        // Find and set current district if exists
        if (_kecamatan != null && selectedDistrictId == null) {
          final currentDistrict = districts.firstWhere(
            (district) => district['name'] == _kecamatan,
            orElse: () => {},
          );
          if (currentDistrict.isNotEmpty) {
            selectedDistrictId = currentDistrict['id'];
          }
        }
      }
    } catch (e) {
      print('Error loading districts: $e');
    } finally {
      setState(() => isLoadingDistricts = false);
    }
  }

  Future<void> fetchStoreData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

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
            _storeDescription = data['data']['deskripsi'] ?? 'Deskripsi tidak tersedia';
            _storeAddress = data['data']['jalan'] ?? 'Alamat tidak tersedia';
            _kecamatan = data['data']['kecamatan'] ?? 'Kecamatan tidak disertakan';
            _kabupaten = data['data']['kabupaten'] ?? 'Kabupaten tidak disertakan';
            _provinsi = data['data']['provinsi'] ?? 'Provinsi tidak disertakan';
            _storeOperationDays = data['data']['waktuBuka'] ?? 'Waktu buka tidak tersedia';
            _storeOperationHours = data['data']['waktuTutup'] ?? 'Waktu tutup tidak tersedia';
            _storeContact = data['data']['noTelp'] ?? 'Kontak tidak tersedia';
            _storeFacebook = data['data']['facebook'] ?? 'Facebook tidak tersedia';
            _storeLogo = data['data']['logo'];
            _isLoading = false;
          });

          _populateControllers();
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

  Future<void> _updateStoreData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate address selections
    if (selectedProvinceName == null || selectedRegencyName == null || selectedDistrictName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap lengkapi semua pilihan alamat'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final updateData = {
        'nama': _nameController.text.trim(),
        'deskripsi': _descriptionController.text.trim(),
        'jalan': _addressController.text.trim(),
        'kecamatan': selectedDistrictName!,
        'kabupaten': selectedRegencyName!,
        'provinsi': selectedProvinceName!,
        'noTelp': _contactController.text.trim(),
        'waktuBuka': _waktuBukaController.text.trim(),
        'waktuTutup': _waktuTutupController.text.trim(),
      };

      final response = await http.put(
        Uri.parse('${Apiconstant.BASE_URL}/toko/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(updateData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          _storeName = _nameController.text;
          _storeDescription = _descriptionController.text;
          _storeAddress = _addressController.text;
          _kecamatan = selectedDistrictName!;
          _kabupaten = selectedRegencyName!;
          _provinsi = selectedProvinceName!;
          _storeContact = _contactController.text;
          _storeOperationDays = _waktuBukaController.text;
          _storeOperationHours = _waktuTutupController.text;
          _isEditMode = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data toko berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(responseData['message'] ?? 'Gagal memperbarui data');
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditMode) {
        _populateControllers();
      }
      _isEditMode = !_isEditMode;
    });
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    if (!_isEditMode) {
      return _buildDetailSection(label, controller.text);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    if (!_isEditMode) {
      return _buildDetailSection(label, controller.text);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          suffixIcon: IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
                controller.text = formattedTime;
              }
            },
          ),
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildAddressDropdown({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required Function(String?) onChanged,
    required bool isLoading,
    String? currentDisplayValue,
  }) {
    if (!_isEditMode) {
      return _buildDetailSection(label, currentDisplayValue ?? 'Tidak tersedia');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text("Pilih $label"),
                value: value,
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['id'],
                    child: Text(item['name']),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          if (isLoading) 
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  // Keep existing methods for review stats and recent reviews
  Future<void> _fetchReviewStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/pengusaha/toko-saya/ulasan/statistik'),
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
        Uri.parse('${Apiconstant.BASE_URL}/pengusaha/toko-saya/ulasan?per_page=3'),
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
              _recentReviews = List<Map<String, dynamic>>.from(data['data']['reviews']);
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

  // Keep existing widget methods for rating, reviews, etc.
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fitur halaman ulasan lengkap akan segera hadir')),
                  );
                },
                child: Text('Lihat Semua'),
              ),
          ],
        ),
        SizedBox(height: 8),
        ...(_recentReviews.take(3).map((review) => _buildReviewItem(review)).toList()),
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final rating = review['rating'] ?? 0;
    final comment = review['review'] ?? '';
    final userName = review['user']?['name'] ?? 'Pengguna';
    final createdAt = review['created_at'] ?? '';
    final kodeTransaksi = review['transaksi']?['kode_transaksi'] ?? '';

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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading && _errorMessage == null)
            IconButton(
              icon: Icon(
                _isEditMode ? Icons.close : Icons.edit,
                color: Colors.white,
              ),
              onPressed: _toggleEditMode,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
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
                        
                        // Store Name (editable)
                        if (_isEditMode)
                          _buildEditableField(
                            label: 'Nama Toko',
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama toko tidak boleh kosong';
                              }
                              return null;
                            },
                          )
                        else
                          Text(
                            _storeName ?? 'Nama Tidak Tersedia',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4EEEC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // Description (editable)
                              _buildEditableField(
                                label: 'Deskripsi',
                                controller: _descriptionController,
                                maxLines: 3,
                                validator: (value) => null, // Optional field
                              ),
                              
                              const SizedBox(height: 16),
                              
                              if (!_isEditMode) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildRatingInfoCard(),
                                    _buildTotalReviewsCard(),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              // Address fields (editable with dropdowns)
                              _buildEditableField(
                                label: 'Alamat Jalan',
                                controller: _addressController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Alamat tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                              
                              // Province Dropdown
                              _buildAddressDropdown(
                                label: 'Provinsi',
                                value: selectedProvinceId,
                                items: provinces,
                                isLoading: isLoadingProvinces,
                                currentDisplayValue: _provinsi,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedProvinceId = newValue;
                                    selectedProvinceName = provinces.firstWhere(
                                      (province) => province['id'] == newValue)['name'];
                                    _loadRegencies(newValue!);
                                  });
                                },
                              ),
                              
                              // Regency Dropdown
                              _buildAddressDropdown(
                                label: 'Kabupaten',
                                value: selectedRegencyId,
                                items: regencies,
                                isLoading: isLoadingRegencies,
                                currentDisplayValue: _kabupaten,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedRegencyId = newValue;
                                    selectedRegencyName = regencies.firstWhere(
                                      (regency) => regency['id'] == newValue)['name'];
                                    _loadDistricts(newValue!);
                                  });
                                },
                              ),
                              
                              // District Dropdown
                              _buildAddressDropdown(
                                label: 'Kecamatan',
                                value: selectedDistrictId,
                                items: districts,
                                isLoading: isLoadingDistricts,
                                currentDisplayValue: _kecamatan,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedDistrictId = newValue;
                                    selectedDistrictName = districts.firstWhere(
                                      (district) => district['id'] == newValue)['name'];
                                  });
                                },
                              ),
                              
                              // Time fields (editable)
                              _buildTimeField(
                                label: 'Waktu Buka',
                                controller: _waktuBukaController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Waktu buka tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                              
                              _buildTimeField(
                                label: 'Waktu Tutup',
                                controller: _waktuTutupController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Waktu tutup tidak boleh kosong';
                                  }
                                  return null;
                                },
                              ),
                              
                              _buildEditableField(
                                label: 'Nomor Telepon',
                                controller: _contactController,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Nomor telepon tidak boleh kosong';
                                  }
                                  if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                                    return 'Nomor telepon harus 10-15 digit';
                                  }
                                  return null;
                                },
                              ),
                              
                              if (!_isEditMode) ...[
                                _buildContactRow("Whatsapp", _storeContact ?? 'N/A', Icons.phone_android_rounded),
                                _buildContactRow("Facebook", _storeFacebook ?? 'N/A', Icons.facebook),
                              ],
                            ],
                          ),
                        ),
                        
                        // Save/Cancel buttons for edit mode
                        if (_isEditMode) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _updateStoreData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF006A55),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Simpan Perubahan',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSaving ? null : _toggleEditMode,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF006A55)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    'Batal',
                                    style: TextStyle(color: Color(0xFF006A55)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        if (!_isEditMode) ...[
                          const SizedBox(height: 20),
                          _buildRecentReviewsSection(),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  // Keep existing helper methods
  Widget _buildInfoCard({required String title, required String value, required IconData icon}) {
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
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          Text("$title : ", style: const TextStyle(fontWeight: FontWeight.bold)),
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