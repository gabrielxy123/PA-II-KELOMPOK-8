import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/pages/order_detail_nota.dart';
import 'package:carilaundry2/pages/order_rating.dart';

class Transaction {
  final String kodeTransaksi;
  final String namaToko;
  final String tanggal;
  final int jumlahItem;
  final int totalHarga;
  final String status;
  
  // Keep these fields with default values for backward compatibility
  final String kontakToko;
  final int idToko;

  Transaction({
    required this.kodeTransaksi,
    required this.namaToko,
    required this.tanggal,
    required this.jumlahItem,
    required this.totalHarga,
    required this.status,
    this.kontakToko = '-',
    this.idToko = 0,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Check if we're using the new JSON format
    if (json.containsKey('jumlah_item')) {
      // New JSON format
      return Transaction(
        kodeTransaksi: json['kode_transaksi'] ?? '',
        namaToko: json['nama_toko'] ?? 'Tidak diketahui',
        tanggal: json['tanggal'] ?? '',
        jumlahItem: json['jumlah_item'] ?? 0,
        totalHarga: json['total_harga'] ?? 0,
        status: json['status'] ?? 'Menunggu',
      );
    } else {
      // Old JSON format
      return Transaction(
        kodeTransaksi: json['kode_transaksi'] ?? '',
        namaToko: json['nama_toko'] ?? 'Tidak diketahui',
        kontakToko: json['kontak_toko'] ?? '-',
        status: json['status'] ?? 'Menunggu',
        idToko: json['id_toko'] ?? 0,
        tanggal: json['created_at'] ?? '',
        jumlahItem: json['total_items'] ?? 0,
        totalHarga: json['total_amount'] ?? 0,
      );
    }
  }

  bool get isOngoing => status == 'Menunggu' || status == 'Diproses';
  bool get isCompleted => status == 'Selesai';
  bool get isRejected => status == 'Ditolak' || status == 'Dibatalkan';
  bool get canReview => isCompleted;
}

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  bool _isRefreshing = false; // Track refresh state separately
  String? _error;

  final String apiUrl = '${Apiconstant.BASE_URL}/nota';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      if (!_isRefreshing) {
        _isLoading = true; // Only show full screen loader on initial load
      }
      _isRefreshing = true; // Always set refreshing to true
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          _error =
              'Silakan login untuk melihat riwayat transaksi.';
          _isLoading = false;
          _isRefreshing = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Check if the response has the new format with "data" field
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final data = responseData['data'] as List<dynamic>;
          final transactions = data.map((e) => Transaction.fromJson(e)).toList();
          setState(() {
            _transactions = transactions;
            _isLoading = false;
            _isRefreshing = false;
          });
        } else {
          // Handle old format
          final data = responseData as List<dynamic>;
          final transactions = data.map((e) => Transaction.fromJson(e)).toList();
          setState(() {
            _transactions = transactions;
            _isLoading = false;
            _isRefreshing = false;
          });
        }
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  String formatCurrency(int amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  String formatDate(String date) {
    try {
      // Try to parse the new date format first (dd-MM-yyyy HH:mm)
      final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
      final parsed = dateFormat.parse(date);
      return DateFormat('dd MMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      try {
        // Fall back to ISO format if the new format fails
        final parsed = DateTime.parse(date);
        return DateFormat('dd MMM yyyy', 'id_ID').format(parsed);
      } catch (_) {
        return date;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter transactions for each tab
    final ongoing = _transactions.where((t) => t.isOngoing).toList();
    final completed = _transactions.where((t) => t.isCompleted).toList();
    final rejected = _transactions.where((t) => t.isRejected).toList();
    final all = _transactions; // All transactions

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Riwayat Transaksi'),
        actions: [
          // Add refresh button to the app bar
          _isRefreshing
              ? Container(
                  margin: const EdgeInsets.all(14),
                  width: 24,
                  height: 24,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: _fetchTransactions,
                ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          indicator: BoxDecoration(color: Color.fromARGB(156, 2, 103, 56)),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Transaksi Terkini'),
            Tab(text: 'Selesai'),
            Tab(text: 'Ditolak'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchTransactions,
                        child: Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchTransactions,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransactionList(all),
                      _buildTransactionList(ongoing),
                      _buildTransactionList(completed),
                      _buildTransactionList(rejected),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTransactionList(List<Transaction> list) {
    if (list.isEmpty) {
      return const Center(child: Text('Tidak ada transaksi'));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildTransactionCard(list[i]),
    );
  }

  Widget _buildTransactionCard(Transaction t) {
    // Determine the status color based on the transaction status
    Color statusColor;
    if (t.isOngoing) {
      statusColor = Colors.orange;
    } else if (t.isCompleted) {
      statusColor = Colors.green;
    } else if (t.isRejected) {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    t.namaToko.isNotEmpty ? t.namaToko[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color.fromARGB(156, 2, 103, 56),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.namaToko,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(t.kontakToko, style: TextStyle(fontSize: 14)),
                    Text(formatDate(t.tanggal),
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${t.jumlahItem} item · ${formatCurrency(t.totalHarga)}',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      t.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              t.canReview
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(156, 2, 103, 56),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderReviewPage(
                              laundryName: t.namaToko,
                              orderId: t.kodeTransaksi,
                            ),
                          ),
                        );
                      },
                      child: const Text('Beri Penilaian',
                          style: TextStyle(fontSize: 11, color: Colors.white)),
                    )
                  : TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OrderDetailPage(kodeTransaksi: t.kodeTransaksi),
                          ),
                        );
                      },
                      child: const Text('Selengkapnya',
                          style: TextStyle(fontSize: 11)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}