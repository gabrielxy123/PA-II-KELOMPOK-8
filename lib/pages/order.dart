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
  final String kontakToko;
  final String status;
  final int idToko;
  final String createdAt;
  final bool isCompleted;
  final int totalItems;
  final int totalAmount;

  Transaction({
    required this.kodeTransaksi,
    required this.namaToko,
    required this.kontakToko,
    required this.status,
    required this.idToko,
    required this.createdAt,
    required this.isCompleted,
    required this.totalItems,
    required this.totalAmount,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      kodeTransaksi: json['kode_transaksi'] ?? '',
      namaToko: json['nama_toko'] ?? 'Tidak diketahui',
      kontakToko: json['kontak_toko'] ?? '-',
      status: json['status'] ?? 'Menunggu',
      idToko: json['id_toko'] ?? 0,
      createdAt: json['created_at'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      totalItems: json['total_items'] ?? 0,
      totalAmount: json['total_amount'] ?? 0,
    );
  }
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
  String? _error;

  final String apiUrl = '${Apiconstant.BASE_URL}/transaksi/riwayat';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final transactions = data.map((e) => Transaction.fromJson(e)).toList();
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd MMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      return date;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ongoing = _transactions.where((t) => !t.isCompleted).toList();
    final completed = _transactions.where((t) => t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Riwayat Transaksi'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          indicator: BoxDecoration(color: Color.fromARGB(156, 2, 103, 56)),
          tabs: const [
            Tab(text: 'Transaksi Terkini'),
            Tab(text: 'Selesai'),
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
                      _buildTransactionList(ongoing),
                      _buildTransactionList(completed),
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
                    Text(t.namaToko, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(t.kontakToko, style: TextStyle(fontSize: 14)),
                    Text(formatDate(t.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${t.totalItems} item · ${formatCurrency(t.totalAmount)}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      t.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: t.isCompleted ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              t.isCompleted
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
                      child: const Text('Beri Penilaian', style: TextStyle(fontSize: 11, color: Colors.white)),
                    )
                  : TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailPage(kodeTransaksi: t.kodeTransaksi),
                          ),
                        );
                      },
                      child: const Text('Selengkapnya', style: TextStyle(fontSize: 11)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
