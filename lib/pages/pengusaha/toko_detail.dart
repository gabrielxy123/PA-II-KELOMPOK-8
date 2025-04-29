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
  List<Map<String, dynamic>> _products = [];
  String? _storeName;
  String? _storeLogo;
  bool _isLoading = true;
  bool _isAddingProduct = false; // New loading state for adding product

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
      final token = prefs.getString('auth_token') ?? '';

      // Fetch store data and products in parallel
      final storeResponse = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/toko-saya'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final productsResponse = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/produks'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (storeResponse.statusCode == 200) {
        final storeData = json.decode(storeResponse.body);
        if (storeData['success'] == true) {
          setState(() {
            _storeName = storeData['data']['nama'];
            _storeLogo = storeData['data']['logo'];
          });
        }
      }

      if (productsResponse.statusCode == 200) {
        final productsData = json.decode(productsResponse.body);
        setState(() {
          _products =
              List<Map<String, dynamic>>.from(productsData['data'] ?? []);
        });
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

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final response = await http.get(
      Uri.parse('${Apiconstant.BASE_URL}/kategoris'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    }
    return [];
  }

  Future<void> _addNewService(
      String categoryId, String nama, String harga) async {
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
        // Refresh data after successful addition
        await _loadStoreData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk berhasil ditambahkan!')),
        );
      } else {
        throw Exception(
            'Gagal menambahkan produk. Status code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan produk: $e')),
      );
    } finally {
      setState(() {
        _isAddingProduct = false;
      });
    }
  }

  Future<void> _showAddServiceDialog() async {
    String? selectedCategory;
    final namaController = TextEditingController();
    final hargaController = TextEditingController();

    final categories = await _fetchCategories();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                    child: Text(category['kategori']),
                  );
                }).toList(),
                onChanged: (value) => selectedCategory = value,
              ),
              SizedBox(height: 16),
              TextField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: hargaController,
                decoration:
                    InputDecoration(labelText: 'Harga Produk (Jika Satuan)'),
                keyboardType: TextInputType.number,
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

                    await _addNewService(
                      selectedCategory!,
                      namaController.text,
                      hargaController.text,
                    );

                    if (!_isAddingProduct) {
                      Navigator.pop(context);
                    }
                  },
            child: _isAddingProduct
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
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
          _storeName ?? 'Toko Laundry',
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
                                context, "/profile-toko-saya");
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
                          onPressed: _isLoading ? null : _showAddServiceDialog,
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
                                      'Tambah Produk',
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
