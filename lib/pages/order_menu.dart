import 'dart:convert';
import 'package:carilaundry2/models/layanan.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/models/produk.dart';
import 'package:carilaundry2/models/kategori.dart';
import 'package:carilaundry2/widgets/service_section.dart';
import 'package:carilaundry2/widgets/additional_service_checkbox.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = true;
  List<Layanan> _additionalServices = [];
  List<Kategori> _kategories = [];
  List<Produk> _produks = [];
  Map<String, String> _selectedServiceTypes = {};
  String? _storeName;
  bool get _isProdukEmpty => _produks.isEmpty;

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchAdditionalServices();
  }

  Future<List<Layanan>> fetchLayanan() async {
    final prefs = await SharedPreferences.getInstance();
    final tokoId = prefs.getInt('id_toko') ?? 0;

    try {
      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/layanan-produks/$tokoId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          final List<dynamic> layananList = data['data'];
          return layananList.map((json) => Layanan.fromJson(json)).toList();
        }
      }
      return []; // Return empty list if error
    } catch (e) {
      print('Error fetching layanan: $e');
      return [];
    }
  }

  Future<void> _fetchAdditionalServices() async {
    try {
      final layananList = await fetchLayanan();
      setState(() {
        _additionalServices = layananList;
      });
    } catch (e) {
      print('Error loading additional services: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat layanan tambahan')),
        );
      }
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final tokoId = prefs.getInt('id_toko') ?? 0;

      // Fetch kategoris
      final kategoriResponse =
          await http.get(Uri.parse('${Apiconstant.BASE_URL}/order-kategoris'));

      // Fetch produks
      final produkResponse = await http
          .get(Uri.parse('${Apiconstant.BASE_URL}/order-produks/$tokoId'));

      // Fetch store data and products in parallel
      final storeResponse = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/detail-toko-user/$tokoId'),
      );

      if (storeResponse.statusCode == 200) {
        final storeData = json.decode(storeResponse.body);
        setState(() {
          _storeName = storeData['data']['nama'];
        });
      }

      if (kategoriResponse.statusCode == 200 &&
          produkResponse.statusCode == 200) {
        final kategoriData = json.decode(kategoriResponse.body);
        final produkData = json.decode(produkResponse.body);

        // Parse kategories
        final List<Kategori> parsedKategories =
            (kategoriData['data'] as List? ?? [])
                .map((json) => Kategori.fromJson(json))
                .toList();

        // Parse produks
        final List<Produk> parsedProduks = (produkData['data'] as List? ?? [])
            .map((json) => Produk.fromJson(json))
            .toList();

        // Initialize service types map
        final Map<String, String> serviceTypes = {};
        for (var kategori in parsedKategories) {
          serviceTypes[kategori.kategori] =
              _isSatuan(kategori.kategori) ? 'Satuan' : 'Kiloan';
        }

        setState(() {
          _kategories = parsedKategories;
          _produks = parsedProduks;
          _selectedServiceTypes = serviceTypes;
        });
      } else {
        throw Exception(
            'API request failed: Kategori ${kategoriResponse.statusCode}, Produk ${produkResponse.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isSatuan(String kategoriNama) {
    return kategoriNama.toLowerCase().contains('satuan');
  }

  int _calculateSubtotalForKategori(Kategori kategori) {
    if (!_isSatuan(kategori.kategori)) return 0;

    final relevantProduks =
        _produks.where((produk) => produk.kategoriId == kategori.id).toList();

    return relevantProduks.fold(
        0, (sum, produk) => sum + (produk.harga * (produk.quantity ?? 0)));
  }

  int get _additionalServicesSubtotal {
    return _additionalServices
        .where((service) => service.isSelected)
        .fold(0, (sum, service) => sum + service.harga.toInt());
  }

  int get _total {
    return _kategories.where((k) => _isSatuan(k.kategori)).fold(0,
            (sum, kategori) => sum + _calculateSubtotalForKategori(kategori)) +
        _additionalServicesSubtotal;
  }

  void _updateQuantity(String produkId, int newQuantity) {
    setState(() {
      final index = _produks.indexWhere((p) => p.id == produkId);
      if (index != -1) {
        _produks[index].quantity = newQuantity;
      }
    });
  }

  void _updateServiceType(String kategoriNama, String newType) {
    setState(() {
      _selectedServiceTypes[kategoriNama] = newType;
    });
  }

  void _toggleAdditionalService(String serviceId, bool value) {
    setState(() {
      final index = _additionalServices.indexWhere((s) => s.id == serviceId);
      if (index != -1) {
        _additionalServices[index].isSelected = value;
      }
    });
  }

  Future<void> _submitOrder() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final tokoId = prefs.getInt('id_toko') ?? 0;

      if (_produks.every((produk) => (produk.quantity ?? 0) == 0)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada produk yang dipilih')),
        );
        return;
      }

      // Pisahkan produk satuan & kiloan
      final List<Map<String, dynamic>> itemSatuan = [];
      final List<Map<String, dynamic>> detailKiloan = [];

      for (var produk in _produks) {
        final quantity = produk.quantity ?? 0;
        if (quantity > 0) {
          final serviceType = _getServiceTypeForProduk(produk);
          if (serviceType == 'Satuan') {
            itemSatuan.add({
              'produk_id': produk.id,
              'quantity': quantity,
              'harga': produk.harga,
            });
          } else {
            detailKiloan.add({
              'id_produk': produk.id,
              'nama_barang': produk.nama,
              'quantity': quantity,
            });
          }
        }
      }

      final orderData = {
        'toko_id': tokoId,
        'items': itemSatuan,
        'pesanan_kiloan': detailKiloan.isNotEmpty
            ? {
                'jumlah_kiloan': null,
                'harga_kiloan': null,
                'details': detailKiloan,
              }
            : null,
      };

      print('Order Data to Send: ${json.encode(orderData)}');

      final response = await http.post(
        Uri.parse('${Apiconstant.BASE_URL}/transaksi'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );

      final responseData = json.decode(response.body);
      print('Response from Server: $responseData');

      if (response.statusCode == 201) {
        if (mounted) {  
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pesanan berhasil dibuat')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Silahkan login terlebih dahulu')));
      }
    } catch (e) {
      print('Error submitting order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat pesanan: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getServiceTypeForProduk(Produk produk) {
    try {
      final kategori = _kategories.firstWhere(
        (k) => k.id == produk.kategoriId,
        orElse: () =>
            throw Exception('Kategori not found for produk ${produk.id}'),
      );

      return _selectedServiceTypes[kategori.kategori] ??
          (_isSatuan(kategori.kategori) ? 'Satuan' : 'Kiloan');
    } catch (e) {
      return 'Kiloan';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_storeName ?? 'Halaman Pemesanan'),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Pesanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dynamic Service Sections
                  for (var kategori in _kategories)
                    _produks
                            .where((produk) => produk.kategoriId == kategori.id)
                            .isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kategori.kategori,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tidak ada produk tersedia untuk kategori ini',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Divider(),
                              ],
                            ),
                          )
                        : ServiceSection(
                            title: kategori.kategori,
                            initialServiceType:
                                _selectedServiceTypes[kategori.kategori] ??
                                    (_isSatuan(kategori.kategori)
                                        ? 'Satuan'
                                        : 'Kiloan'),
                            serviceTypes: _isSatuan(kategori.kategori)
                                ? ['Satuan']
                                : ['Kiloan'],
                            produkItems: _produks
                                .where((produk) =>
                                    produk.kategoriId == kategori.id)
                                .toList(),
                            onQuantityChanged: (produkId, quantity) =>
                                _updateQuantity(produkId, quantity),
                            onServiceTypeChanged: (type) =>
                                _updateServiceType(kategori.kategori, type),
                            showItemPrices: _isSatuan(kategori.kategori),
                            showSubtotal: _isSatuan(kategori.kategori),
                            isPriced: _isSatuan(kategori.kategori),
                          ),

                  // Additional Services
                  // Ganti bagian Additional Services di build method
                  // Additional Services
                  if (_additionalServices.isNotEmpty) ...[
                    const Text(
                      'Layanan Tambahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._additionalServices.map(
                      (service) => AdditionalServiceCheckbox(
                        name: service.nama,
                        price: service.harga.toInt(),
                        isSelected: service.isSelected,
                        onChanged: (value) => _toggleAdditionalService(
                            service.id, value ?? false),
                      ),
                    ),
                    if (_additionalServicesSubtotal > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Subtotal: '),
                            Text('Rp$_additionalServicesSubtotal'),
                          ],
                        ),
                      ),
                  ] else ...[
                    const Text(
                      'Layanan Tambahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tidak ada layanan tambahan tersedia.',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  // Notes
                  const Text(
                    'Catatan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan catatan...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),

          // Order Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006A4E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Buat Pesanan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
