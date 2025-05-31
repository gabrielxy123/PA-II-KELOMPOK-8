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
    if (json.containsKey('jumlah_item')) {
      return Transaction(
        kodeTransaksi: json['kode_transaksi'] ?? '',
        namaToko: json['nama_toko'] ?? 'Tidak diketahui',
        tanggal: json['tanggal'] ?? '',
        kontakToko: json['noTelp'] ?? '-',
        jumlahItem: json['jumlah_item'] ?? 0,
        totalHarga: json['total_harga'] ?? 0,
        status: json['status'] ?? 'Menunggu',
      );
    } else {
      return Transaction(
        kodeTransaksi: json['kode_transaksi'] ?? '',
        namaToko: json['nama_toko'] ?? 'Tidak diketahui',
        kontakToko: json['noTelp'] ?? '-',
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

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Icons.access_time;
      case 'diproses':
        return Icons.autorenew;
      case 'selesai':
        return Icons.check_circle;
      case 'ditolak':
      case 'dibatalkan':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
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
  bool _isRefreshing = false;
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
        _isLoading = true;
      }
      _isRefreshing = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          _error = 'Silakan login untuk melihat riwayat transaksi.';
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

        List<Transaction> transactions = [];
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          final data = responseData['data'] as List<dynamic>;
          transactions = data.map((e) => Transaction.fromJson(e)).toList();
        } else if (responseData is List<dynamic>) {
          transactions =
              responseData.map((e) => Transaction.fromJson(e)).toList();
        }

        setState(() {
          _transactions = transactions;
          _isLoading = false;
          _isRefreshing = false;

          if (transactions.isEmpty) {
            _error = 'Tidak ada transaksi yang ditemukan.';
          }
        });
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
      final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
      final parsed = dateFormat.parse(date);
      return DateFormat('dd MMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      try {
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
    final ongoing = _transactions.where((t) => t.isOngoing).toList();
    final completed = _transactions.where((t) => t.isCompleted).toList();
    final rejected = _transactions.where((t) => t.isRejected).toList();
    final all = _transactions;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF006A55),
        elevation: 0,
        actions: [
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
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh',
                  onPressed: _fetchTransactions,
                ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: const Color(0xFF006A55),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: [
                Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Semua'),
                      if (all.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${all.length}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Terkini'),
                      if (ongoing.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${ongoing.length}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Selesai'),
                      if (completed.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${completed.length}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Ditolak'),
                      if (rejected.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${rejected.length}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF006A55)),
                  ),
                  SizedBox(height: 16),
                  Text('Memuat riwayat transaksi...'),
                ],
              ),
            )
          : _error != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _fetchTransactions,
                  color: const Color(0xFF006A55),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransactionList(all, 'Semua Transaksi'),
                      _buildTransactionList(ongoing, 'Transaksi Terkini'),
                      _buildTransactionList(completed, 'Transaksi Selesai'),
                      _buildTransactionList(rejected, 'Transaksi Ditolak'),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (_error!.contains('login')) {
                  Navigator.pushNamed(context, "/login");
                } else {
                  _fetchTransactions();
                }
              },
              icon:
                  Icon(_error!.contains('login') ? Icons.login : Icons.refresh),
              label: Text(_error!.contains('login') ? 'Login' : 'Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006A55),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> list, String tabName) {
    if (list.isEmpty) {
      return _buildEmptyState(tabName);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildTransactionCard(list[i]),
    );
  }

  Widget _buildEmptyState(String tabName) {
    IconData icon;
    String message;
    String subtitle;

    switch (tabName) {
      case 'Transaksi Terkini':
        icon = Icons.access_time;
        message = 'Tidak ada transaksi terkini';
        subtitle = 'Transaksi yang sedang diproses akan muncul di sini';
        break;
      case 'Transaksi Selesai':
        icon = Icons.check_circle_outline;
        message = 'Belum ada transaksi selesai';
        subtitle = 'Transaksi yang telah selesai akan muncul di sini';
        break;
      case 'Transaksi Ditolak':
        icon = Icons.cancel_outlined;
        message = 'Tidak ada transaksi ditolak';
        subtitle = 'Transaksi yang ditolak akan muncul di sini';
        break;
      default:
        icon = Icons.receipt_long_outlined;
        message = 'Belum ada transaksi';
        subtitle =
            'Mulai pesan layanan laundry untuk melihat riwayat transaksi';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            if (tabName == 'Semua Transaksi') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, "/home");
                },
                icon: const Icon(Icons.add),
                label: const Text('Mulai Pesan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006A55),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailPage(kodeTransaksi: t.kodeTransaksi),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Store Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF006A55),
                            const Color(0xFF006A55).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          t.namaToko.isNotEmpty
                              ? t.namaToko[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Transaction Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t.namaToko,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: t.statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: t.statusColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      t.statusIcon,
                                      size: 12,
                                      color: t.statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      t.status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: t.statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kode: ${t.kodeTransaksi}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatDate(t.tanggal),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Transaction Details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${t.jumlahItem} item',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatCurrency(t.totalHarga),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006A55),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: t.canReview
                      ? ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderReviewPage(
                                  laundryName: t.namaToko,
                                  kodeTransaksi: t.kodeTransaksi,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.star_outline, size: 18),
                          label: const Text('Beri Penilaian'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006A55),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailPage(
                                    kodeTransaksi: t.kodeTransaksi),
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('Lihat Detail'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF006A55),
                            side: const BorderSide(color: Color(0xFF006A55)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),  
    );
  }
}
