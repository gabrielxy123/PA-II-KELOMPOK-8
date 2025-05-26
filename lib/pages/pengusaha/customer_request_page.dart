import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/pages/pengusaha/customer_request_page_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerRequestPage extends StatefulWidget {
  const CustomerRequestPage({Key? key}) : super(key: key);

  @override
  _CustomerRequestPageState createState() => _CustomerRequestPageState();
}

class _CustomerRequestPageState extends State<CustomerRequestPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> _requests = [];
  Map<String, List<dynamic>> _categorizedRequests = {
    'Semua': [],
    'Menunggu': [],
    'Diproses': [],
    'Selesai': [],
    'Ditolak': [],
  };

  bool _isLoading = true;
  String? _error;
  TabController? _tabController;

  final List<String> _tabs = [
    'Semua',
    'Menunggu',
    'Diproses',
    'Selesai',
    'Ditolak',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    fetchCustomerRequests();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _categorizeRequests() {
    // Clear previous categorized data
    for (var key in _categorizedRequests.keys) {
      _categorizedRequests[key] = [];
    }

    // Add all requests to "Semua" category
    _categorizedRequests['Semua'] = List.from(_requests);

    // Categorize requests by status
    for (var request in _requests) {
      final status = (request['status'] ?? '').toLowerCase();

      if (status.contains('menunggu')) {
        _categorizedRequests['Menunggu']!.add(request);
      } else if (status.contains('proses')) {
        _categorizedRequests['Diproses']!.add(request);
      } else if (status.contains('selesai')) {
        _categorizedRequests['Selesai']!.add(request);
      } else if (status.contains('ditolak')) {
        _categorizedRequests['Ditolak']!.add(request);
      }
    }
  }

  Future<void> fetchCustomerRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          _isLoading = false;
          _error = 'Token tidak ditemukan. Silakan login kembali.';
        });
        return;
      }

      final response = await http.get(
          Uri.parse('${Apiconstant.BASE_URL}/pengusaha/transaksi'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          });

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        // Cek jika data kosong atau tidak ada
        if (responseBody['data'] == null || responseBody['data'].isEmpty) {
          setState(() {
            _requests = [];
            _isLoading = false;
            _error = 'Tidak ada pesanan yang ditemukan.';
          });
        } else {
          setState(() {
            _requests = responseBody['data'];
            _categorizeRequests();
            _isLoading = false;
          });
        }
      } else {
        // Handle error response dari server
        final errorMessage = responseBody['message'] ??
            'Gagal memuat data: ${response.statusCode}';
        setState(() {
          _isLoading = false;
          _error = errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String formatCurrency(dynamic number) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (number is String) {
      return formatter.format(int.tryParse(number) ?? 0);
    } else if (number is int) {
      return formatter.format(number);
    } else {
      return formatter.format(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permintaan Pelanggan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchCustomerRequests,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) {
            final count = _categorizedRequests[tab]?.length ?? 0;
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tab),
                  const SizedBox(width: 4),
                  if (!_isLoading && count > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // Set physics to NeverScrollableScrollPhysics to prevent swiping between tabs
        // This ensures all tabs are prerendered and ready
        physics: const NeverScrollableScrollPhysics(),
        children: _tabs.map((tab) {
          return RefreshIndicator(
            onRefresh: fetchCustomerRequests,
            child: _error != null
                ? _ErrorView(error: _error!, onRetry: fetchCustomerRequests)
                : _categorizedRequests[tab]!.isEmpty
                    ? _isLoading
                        ? const _LoadingView()
                        : _EmptyView(currentTab: tab)
                    : _RequestListView(
                        requests: _categorizedRequests[tab]!,
                        formatCurrency: formatCurrency,
                        isLoading: _isLoading,
                      ),
          );
        }).toList(),
      ),
    );
  }
}

class _RequestListView extends StatelessWidget {
  final List<dynamic> requests;
  final String Function(dynamic) formatCurrency;
  final bool isLoading;

  const _RequestListView({
    Key? key,
    required this.requests,
    required this.formatCurrency,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _LoadingView();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(context, request);
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, dynamic request) {
    final status = request['status'] ?? 'Menunggu';
    final statusInfo = _getStatusInfo(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with transaction code and status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.blue),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Kode: ${request['kode_transaksi']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(statusInfo),
              ],
            ),
          ),

          // Customer info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer name
                Row(
                  children: [
                    const Icon(Icons.person, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request['nama_pelanggan'] ?? 'Pelanggan',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      request['tanggal'] ?? 'Tanggal tidak tersedia',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Items count
                Row(
                  children: [
                    const Icon(Icons.local_laundry_service,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '${request['jumlah_item'] ?? 0} item',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Total price
                Row(
                  children: [
                    const Icon(Icons.payments, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      formatCurrency(request['total_harga'] ?? 0),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Navigate to detail page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerRequestDetailPage(
                              kodeTransaksi: request['kode_transaksi'],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Lihat Detail'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> statusInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusInfo['color'].withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo['icon'],
            size: 14,
            color: statusInfo['color'],
          ),
          const SizedBox(width: 4),
          Text(
            statusInfo['label'],
            style: TextStyle(
              color: statusInfo['color'],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    final statusLower = status.toLowerCase();

    if (statusLower.contains('selesai')) {
      return {
        'label': 'Selesai',
        'color': Colors.green,
        'icon': Icons.check_circle,
      };
    } else if (statusLower.contains('proses')) {
      return {
        'label': 'Diproses',
        'color': Colors.orange,
        'icon': Icons.hourglass_empty,
      };
    } else if (statusLower.contains('ditolak')) {
      return {
        'label': 'Ditolak',
        'color': Colors.red,
        'icon': Icons.cancel,
      };
    } else {
      return {
        'label': 'Menunggu',
        'color': Colors.blue,
        'icon': Icons.access_time,
      };
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 150,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),

              // Shimmer content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    4,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Shimmer action button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({Key? key, required this.error, required this.onRetry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String currentTab;

  const _EmptyView({Key? key, required this.currentTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Permintaan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            currentTab == 'Semua'
                ? 'Belum ada permintaan pelanggan saat ini'
                : 'Belum ada permintaan dengan status "$currentTab"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
