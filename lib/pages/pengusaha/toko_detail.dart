import 'package:carilaundry2/models/layanan.dart';
import 'package:carilaundry2/models/produk.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:intl/intl.dart';

class TokoDetailPage extends StatefulWidget {
  @override
  _TokoDetailPageState createState() => _TokoDetailPageState();
}

class _TokoDetailPageState extends State<TokoDetailPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _layanans = [];
  String? _storeName;
  String? _storeLogo;
  String? _storeTelp;
  bool _isLoading = true;
  bool _isAddingProduct = false;
  bool _isAddingLayanan = false;

  // Review stats variables
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
      final token = prefs.getString('auth_token') ?? '';

      // --- Store Data ---
      final storeResponse = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/toko-saya'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (storeResponse.statusCode == 200) {
        final storeData = json.decode(storeResponse.body);
        if (storeData['data'] != null) {
          setState(() {
            _storeName = storeData['data']['nama'];
            _storeLogo = storeData['data']['logo'];
            _storeTelp = storeData['data']['noTelp'];
          });
        }
      } else {
        print('Failed to load store data: ${storeResponse.statusCode}');
        print('Store Response Body: ${storeResponse.body}');
      }

      // --- Review Stats Data --- (TAMBAHAN BARU)
      await _fetchReviewStats(token);

      // --- Products Data ---
      print('Fetching products...');
      final productsResponse = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/produks'),
        headers: {'Authorization': 'Bearer $token'},
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
        Uri.parse('${Apiconstant.BASE_URL}/layanan'),
        headers: {'Authorization': 'Bearer $token'},
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

  // SEMUA METHOD LAINNYA TETAP SAMA (delete, edit, add, dll.)
  Future<void> _deleteProduct(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.delete(
        Uri.parse('${Apiconstant.BASE_URL}/delete-produk/$productId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        await _loadStoreData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produk berhasil dihapus!')),
          );
        }
      } else {
        final responseBody = json.decode(response.body);
        throw Exception(
            'Gagal menghapus produk. Status: ${response.statusCode}, Pesan: ${responseBody['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus produk: $e')),
        );
      }
    }
  }

  Future<void> _deleteLayanan(String layananId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.delete(
        Uri.parse('${Apiconstant.BASE_URL}/delete-layanan/$layananId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        await _loadStoreData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Layanan berhasil dihapus!')),
          );
        }
      } else {
        final responseBody = json.decode(response.body);
        throw Exception(
            'Gagal menghapus layanan. Status: ${response.statusCode}, Pesan: ${responseBody['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus layanan: $e')),
        );
      }
    }
  }

  Future<void> _editProduct(
      String productId, String categoryId, String nama, double? harga) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.put(
        Uri.parse('${Apiconstant.BASE_URL}/edit-produk/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nama': nama,
          'harga': harga,
          'id_kategori': categoryId,
        }),
      );

      if (response.statusCode == 200) {
        await _loadStoreData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produk berhasil diperbarui!')),
          );
        }
      } else {
        final responseBody = json.decode(response.body);
        throw Exception(
            'Gagal memperbarui produk. Status: ${response.statusCode}, Pesan: ${responseBody['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui produk: $e')),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _checkKiloanPriceExistsAndValue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/cek-harga-kiloan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        return {'exists': jsonBody['exists'], 'harga': jsonBody['harga']};
      } else {
        throw Exception('Gagal cek harga kiloan');
      }
    } catch (e) {
      print('Error: $e');
      return {
        'exists': false,
        'harga': null,
      };
    }
  }

  // NEW: Edit Service Function
  Future<void> _editLayanan(String layananId, String nama, String harga) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.put(
        Uri.parse('${Apiconstant.BASE_URL}/edit-layanan/$layananId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nama': nama,
          'harga': harga,
        }),
      );

      if (response.statusCode == 200) {
        await _loadStoreData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Layanan berhasil diperbarui!')),
          );
        }
      } else {
        final responseBody = json.decode(response.body);
        throw Exception(
            'Gagal memperbarui layanan. Status: ${response.statusCode}, Pesan: ${responseBody['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui layanan: $e')),
        );
      }
    }
  }

  Future<void> _showEditProductDialog(Produk produk) async {
    final categories = await _fetchCategories();

    print('Available categories: $categories');
    print('Product category ID: ${produk.id}');

    String? selectedCategory;

    if (produk.id != null) {
      final productCategoryId = produk.id.toString();

      final categoryExists = categories
          .any((category) => category['id'].toString() == productCategoryId);

      if (categoryExists) {
        selectedCategory = productCategoryId;
      } else {
        selectedCategory = null;
        print(
            'Warning: Product category ID $productCategoryId not found in available categories');
      }
    }

    final namaController = TextEditingController(text: produk.nama);
    final hargaController =
        TextEditingController(text: produk.harga.toString());

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Produk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Pilih Kategori',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedCategory,
                  hint: Text('Pilih kategori produk'),
                  isExpanded: true,
                  items: categories.map<DropdownMenuItem<String>>((category) {
                    final categoryId = category['id'].toString();
                    final categoryName = category['kategori']?.toString() ??
                        'Kategori tidak diketahui';

                    return DropdownMenuItem<String>(
                      value: categoryId,
                      child: Text(
                        categoryName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Kategori harus dipilih' : null,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: 'Nama Produk',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: hargaController,
                  decoration: InputDecoration(
                    labelText: 'Harga Produk (Satuan)',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Harap pilih kategori')),
                  );
                  return;
                }

                if (namaController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Harap isi nama produk')),
                  );
                  return;
                }

                double? harga;
                if (hargaController.text.trim().isNotEmpty) {
                  harga = double.tryParse(hargaController.text.trim());
                  if (harga == null || harga < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Harga harus berupa angka yang valid')),
                    );
                    return;
                  }
                }

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  await _editProduct(
                    produk.id.toString(),
                    selectedCategory!,
                    namaController.text.trim(),
                    harga,
                  );

                  Navigator.pop(context);
                  Navigator.pop(context);
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal memperbarui produk: $e')),
                  );
                }
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditLayananDialog(Layanan layanan) async {
    final namaLayananController = TextEditingController(text: layanan.nama);
    final hargaLayananController =
        TextEditingController(text: layanan.harga.toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Layanan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaLayananController,
                decoration: InputDecoration(labelText: 'Nama Layanan'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: hargaLayananController,
                decoration: InputDecoration(labelText: 'Harga Layanan'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (namaLayananController.text.isEmpty ||
                  hargaLayananController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Harap isi semua field')),
                );
                return;
              }

              if (double.tryParse(hargaLayananController.text) == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Harga harus berupa angka')),
                );
                return;
              }

              await _editLayanan(
                layanan.id.toString(),
                namaLayananController.text,
                hargaLayananController.text,
              );

              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showProductActionMenu(Produk produk) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('Edit Produk'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditProductDialog(produk);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Hapus Produk'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(
                    title: 'Hapus Produk',
                    content:
                        'Apakah Anda yakin ingin menghapus produk "${produk.nama}"?',
                    onConfirm: () => _deleteProduct(produk.id.toString()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLayananActionMenu(Layanan layanan) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('Edit Layanan'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditLayananDialog(layanan);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Hapus Layanan'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(
                    title: 'Hapus Layanan',
                    content:
                        'Apakah Anda yakin ingin menghapus layanan "${layanan.nama}"?',
                    onConfirm: () => _deleteLayanan(layanan.id.toString()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    try {
      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/kategoris'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Categories API Response: $data');

        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<void> _addNewService(
      String categoryId, String nama, double? harga) async {
    setState(() {
      _isAddingProduct = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.post(
        Uri.parse('${Apiconstant.BASE_URL}/tambah-produk'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nama': nama,
          'harga': harga,
          'id_kategori': categoryId,
        }),
      );

      if (response.statusCode == 201) {
        await _loadStoreData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produk berhasil ditambahkan!')),
          );
        }
      } else {
        final responseBody = json.decode(response.body);
        throw Exception(
            'Gagal menambahkan produk. Status: ${response.statusCode}, Pesan: ${responseBody['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan produk: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingProduct = false;
        });
      }
    }
  }

  Future<void> _addLayanan(String nama, String harga) async {
    setState(() {
      _isAddingLayanan = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.post(
        Uri.parse('${Apiconstant.BASE_URL}/tambah-layanan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nama': nama,
          'harga': harga,
        }),
      );

      if (response.statusCode == 201) {
        await _loadStoreData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Layanan Tambahan berhasil ditambahkan!')),
          );
        }
      } else {
        final responseBody = json.decode(response.body);
        throw Exception(
            'Gagal menambahkan Layanan Tambahan. Status: ${response.statusCode}, Pesan: ${responseBody['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan Layanan Tambahan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingLayanan = false;
        });
      }
    }
  }

  Future<void> _showAddServiceDialog() async {
    String? selectedCategory;
    final namaController = TextEditingController();
    final hargaController = TextEditingController();

    final categories = await _fetchCategories();
    bool isKiloanCategory = false;
    bool kiloanPriceExists = false;
    double? existingKiloanPrice;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Tambah Produk Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Pilih Kategori'),
                  value: selectedCategory,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category['id'].toString(),
                      child: Text(
                          category['kategori'] ?? 'Kategori tidak diketahui'),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    selectedCategory = value;
                    setState(() {
                      isKiloanCategory = value == '2';
                    });

                    if (isKiloanCategory) {
                      final result = await _checkKiloanPriceExistsAndValue();
                      setState(() {
                        kiloanPriceExists = result['exists'] ?? false;
                        existingKiloanPrice = (result['harga'] != null)
                            ? (result['harga'] is int
                                ? (result['harga'] as int).toDouble()
                                : result['harga'] as double)
                            : null;
                      });
                    } else {
                      setState(() {
                        kiloanPriceExists = false;
                        existingKiloanPrice = null;
                      });
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Kategori harus dipilih' : null,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: namaController,
                  decoration: InputDecoration(labelText: 'Nama Produk'),
                ),
                SizedBox(height: 16),
                if (!isKiloanCategory ||
                    (isKiloanCategory && !kiloanPriceExists))
                  TextField(
                    controller: hargaController,
                    decoration: InputDecoration(labelText: 'Harga Produk'),
                    keyboardType: TextInputType.number,
                  ),
                if (isKiloanCategory && kiloanPriceExists)
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Harga dasar untuk pesanan kiloan adalah Rp ${existingKiloanPrice?.toStringAsFixed(0)}. '
                            'Anda dapat mengubah harga dasar pesanan kiloan dengan mengedit salah satu produk kiloan.',
                            style: TextStyle(color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isAddingProduct ? null : () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: _isAddingProduct
                  ? null
                  : () async {
                      if (selectedCategory == null ||
                          namaController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Harap isi semua field')),
                        );
                        return;
                      }

                      double? harga;
                      if (!isKiloanCategory ||
                          (isKiloanCategory && !kiloanPriceExists)) {
                        if (hargaController.text.isNotEmpty) {
                          harga = double.tryParse(hargaController.text);
                          if (harga == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Harga harus berupa angka')),
                            );
                            return;
                          }
                        }
                      }

                      await _addNewService(
                        selectedCategory!,
                        namaController.text,
                        harga,
                      );

                      if (mounted && !_isAddingProduct) {
                        Navigator.pop(context);
                      }
                    },
              child: _isAddingProduct
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddLayananDialog() async {
    final namaLayananController = TextEditingController();
    final hargaLayananController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Layanan Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaLayananController,
                decoration: InputDecoration(labelText: 'Nama Layanan'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: hargaLayananController,
                decoration: InputDecoration(labelText: 'Harga Layanan'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isAddingLayanan ? null : () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _isAddingLayanan
                ? null
                : () async {
                    if (namaLayananController.text.isEmpty ||
                        hargaLayananController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Harap isi semua field')),
                      );
                      return;
                    }
                    if (double.tryParse(hargaLayananController.text) == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Harga harus berupa angka')),
                      );
                      return;
                    }

                    await _addLayanan(
                      namaLayananController.text,
                      hargaLayananController.text,
                    );

                    if (mounted && !_isAddingLayanan) {
                      Navigator.pop(context);
                    }
                  },
            child: _isAddingLayanan
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text('Simpan'),
          ),
        ],
      ),
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
        backgroundColor: Colors.white,
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
                          Navigator.pushNamed(context, "/profile-toko-saya");
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
                    'Jenis-jenis Layanan Toko Anda',
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
              ],
            ),
    );
  }

  Widget _buildProductGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAddButton(onTap: _showAddServiceDialog),
                  SizedBox(height: 16),
                  Text("Belum ada produk laundry."),
                  Text("Klik tombol '+' untuk menambahkan."),
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
              itemCount: _products.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddButton(onTap: _showAddServiceDialog);
                }

                final productIndex = index - 1;

                if (productIndex >= _products.length) {
                  return const SizedBox.shrink();
                }

                try {
                  final productMap = _products[productIndex];
                  final produk = Produk.fromJson(productMap);
                  return _buildProdukItem(produk, onTap: () {});
                } catch (e) {
                  print('Error building product item $productIndex: $e');
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
                  _buildAddButton(onTap: _showAddLayananDialog),
                  SizedBox(height: 16),
                  Text("Belum ada layanan tambahan laundry."),
                  Text("Klik tombol '+' untuk menambahkan."),
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
              itemCount: _layanans.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddButton(onTap: _showAddLayananDialog);
                }

                final layananIndex = index - 1;

                if (layananIndex >= _layanans.length) {
                  return const SizedBox.shrink();
                }

                try {
                  final layananMap = _layanans[layananIndex];
                  final layanan = Layanan.fromJson(layananMap);
                  return _buildLayananItem(layanan, onTap: () {});
                } catch (e) {
                  print('Error building product item $layananIndex: $e');
                  return _buildErrorItem();
                }
              },
            ),
    );
  }

  Widget _buildAddButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF006A55),
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
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Tambahkan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProdukItem(Produk produk, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showProductActionMenu(produk),
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
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: (produk.logoUrl != null &&
                            produk.logoUrl!.isNotEmpty)
                        ? Image.network(
                            produk.logoUrl!,
                            fit: BoxFit.contain,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
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
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _showProductActionMenu(produk),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
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
      onLongPress: () => _showLayananActionMenu(layanan),
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
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: (layanan.logoUrl != null &&
                            layanan.logoUrl!.isNotEmpty)
                        ? Image.network(
                            layanan.logoUrl!,
                            fit: BoxFit.contain,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
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
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _showLayananActionMenu(layanan),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
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
