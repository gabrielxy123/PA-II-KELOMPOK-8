import 'dart:convert';
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
  List<Kategori> _kategories = [];
  List<Produk> _produks = [];
  Map<String, String> _selectedServiceTypes = {};
  String? _storeName;
  bool get _isProdukEmpty => _produks.isEmpty;

  final List<Map<String, dynamic>> additionalServices = [
    {'id': 1, 'name': 'Extra Pelembut', 'price': 5000, 'isSelected': false},
    {'id': 2, 'name': 'Extra Pewangi', 'price': 3000, 'isSelected': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
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
    return additionalServices
        .where((service) => service['isSelected'] == true)
        .fold(0, (sum, service) => sum + (service['price'] as int));
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

  void _toggleAdditionalService(int serviceId, bool value) {
    setState(() {
      final index = additionalServices.indexWhere((s) => s['id'] == serviceId);
      if (index != -1) {
        additionalServices[index]['isSelected'] = value;
      }
    });
  }

  Future<void> _submitOrder() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final tokoId = prefs.getInt('id_toko') ?? 0;

      final orderData = {
        'toko_id': tokoId,
        'items': [
          for (var produk in _produks)
            if ((produk.quantity ?? 0) > 0)
              {
                'produk_id': produk.id,
                'quantity': produk.quantity ?? 0,
                'harga': produk.harga,
                'jenis_layanan': _getServiceTypeForProduk(produk),
              },
        ],
        'layanan_tambahan': [
          for (var service in additionalServices)
            if (service['isSelected'] == true)
              {
                'layanan_id': service['id'],
                'harga': service['price'],
              },
        ],
        'catatan': _notesController.text,
        'total': _total,
      };

      final response = await http.post(
        Uri.parse('${Apiconstant.BASE_URL}/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Gagal membuat pesanan: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat pesanan: $e')),
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
                  if (additionalServices.isNotEmpty) ...[
                    const Text(
                      'Layanan Tambahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...additionalServices.map(
                      (service) => AdditionalServiceCheckbox(
                        name: service['name'],
                        price: service['price'],
                        isSelected: service['isSelected'],
                        onChanged: (value) =>
                            _toggleAdditionalService(service['id'], value),
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
                  ],

                  const Divider(thickness: 1),
                  const SizedBox(height: 16),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rp$_total',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006A4E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

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
