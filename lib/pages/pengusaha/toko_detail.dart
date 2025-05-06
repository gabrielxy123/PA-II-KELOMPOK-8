import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carilaundry2/core/apiConstant.dart';

class TokoDetailPage extends StatefulWidget {
  @override
  _TokoDetailPageState createState() => _TokoDetailPageState();
}

class _TokoDetailPageState extends State<TokoDetailPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _products = [];
  String? _storeName;
  String? _storeLogo;
  bool _isLoading = true;
  bool _isAddingProduct = false;
  
  // Tab controller for swipeable tabs
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

  // Keep the original API loading function unchanged
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
          _products = List<Map<String, dynamic>>.from(productsData['data'] ?? []);
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

  // Keep the original categories fetch function unchanged
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

  // Keep the original add service function unchanged
  Future<void> _addNewService(String categoryId, String nama, String harga) async {
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
        throw Exception('Gagal menambahkan produk. Status code: ${response.statusCode}');
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

  // Keep the original dialog function unchanged
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
                decoration: InputDecoration(labelText: 'Harga Produk (Jika Satuan)'),
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
                    if (selectedCategory == null || namaController.text.isEmpty) {
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
          'Toko Anda',
          style: TextStyle(fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 20),
            onPressed: () {
              // Aksi untuk pengaturan toko
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Store header with green background
                Container(
                  color: const Color(0xFF006A55),
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Store logo
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, "/profile-toko-saya");
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(8.0),
                            child: _buildLogo(_storeLogo),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Store info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _storeName ?? 'Laundry Fanya',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'No. Telp 082232323234',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.yellow, size: 16),
                                Text(
                                  ' 4.8 (244)',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Service types title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Jenis-jenis Layanan Toko Anda',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                
                // Tab bar for categories
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF006A55),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF006A55),
                  tabs: [
                    Tab(text: 'Kategori Laundry'),
                    Tab(text: 'Kategori Tambahan'),
                  ],
                ),
                
                // Tab content with swipeable views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Kategori Laundry Tab
                      _buildProductGrid(),
                      
                      // Kategori Tambahan Tab
                      _buildAdditionalProductGrid(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildProductGrid() {
    // This is a placeholder for the laundry category products
    // In a real implementation, you would filter products by category
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          // Add product button (green plus button)
          _buildAddButton(),
          
          // Sample product items for the laundry category
          _buildServiceItem('Kemeja', ''),
          _buildServiceItem('Celana', ''),
          _buildServiceItem('Jaket', ''),
          _buildServiceItem('Sepatu', ''),
          _buildServiceItem('Selimut', ''),
          _buildServiceItem('Kaos', ''),
        ],
      ),
    );
  }
  
  Widget _buildAdditionalProductGrid() {
    // This is a placeholder for the additional category products
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          // Add product button (green plus button)
          _buildAddButton(),
          
          // Sample product items for the additional category
          _buildServiceItem('Extra Pelembut', ''),
          _buildServiceItem('Extra Pewangi', ''),
        ],
      ),
    );
  }
  
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showAddServiceDialog,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF006A55),
          borderRadius: BorderRadius.circular(8),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String title, String imagePath) {
    return Container(
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
        children: [
          Container(
            height: 60,
            width: 60,
            padding: EdgeInsets.all(8),
            child: imagePath.isNotEmpty
                ? Image.network(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.local_laundry_service, size: 40, color: Colors.grey);
                    },
                  )
                : Icon(Icons.local_laundry_service, size: 40, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
        color: Colors.grey,
      ),
    );
  }
}
