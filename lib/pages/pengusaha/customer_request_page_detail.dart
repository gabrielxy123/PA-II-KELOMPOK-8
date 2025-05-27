import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:carilaundry2/core/apiConstant.dart';

class CustomerRequestDetailPage extends StatefulWidget {
  final String kodeTransaksi;

  const CustomerRequestDetailPage({Key? key, required this.kodeTransaksi})
      : super(key: key);

  @override
  _CustomerRequestDetailPageState createState() =>
      _CustomerRequestDetailPageState();
}

class _CustomerRequestDetailPageState extends State<CustomerRequestDetailPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _requestDetail;

  // Controllers for kiloan input
  final TextEditingController _jumlahKiloanController = TextEditingController();
  final TextEditingController _hargaKiloanController = TextEditingController();
  final TextEditingController _rejectionReasonController =
      TextEditingController();

  // Flag to track if kiloan data is being edited
  bool _isEditingKiloan = false;

  // Flag to track if we need to show kiloan warning
  bool _showKiloanWarning = false;

  @override
  void initState() {
    super.initState();
    _fetchRequestDetail(widget.kodeTransaksi);
  }

  @override
  void dispose() {
    _jumlahKiloanController.dispose();
    _hargaKiloanController.dispose();
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequestDetail(String kodeTransaksi) async {
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
        Uri.parse('${Apiconstant.BASE_URL}/pengusaha/transaksi/$kodeTransaksi'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == 'Nota berhasil diambil') {
          setState(() {
            _requestDetail = data['data'];
            _isLoading = false;

            // Check if this is a kiloan order that needs data
            if (_requestDetail != null &&
                _requestDetail!['id_pesanan_kiloan'] != null &&
                _requestDetail!['pesanan_kiloan'] != null) {
              // Initialize controllers with existing values if available
              if (_requestDetail!['pesanan_kiloan']['jumlah_kiloan'] != null) {
                _jumlahKiloanController.text = _requestDetail!['pesanan_kiloan']
                        ['jumlah_kiloan']
                    .toString();
              }

              if (_requestDetail!['pesanan_kiloan']['harga_kiloan'] != null) {
                _hargaKiloanController.text = _requestDetail!['pesanan_kiloan']
                        ['harga_kiloan']
                    .toString();
              }

              // Show warning if kiloan data is missing and status is "menunggu"
              if ((_requestDetail!['pesanan_kiloan']['jumlah_kiloan'] == null ||
                      _requestDetail!['pesanan_kiloan']['harga_kiloan'] ==
                          null) &&
                  _requestDetail!['status']?.toString().toLowerCase() ==
                      'menunggu') {
                _showKiloanWarning = true;

                // Auto-open edit mode if data is missing
                if (!_isEditingKiloan) {
                  _isEditingKiloan = true;
                }
              } else {
                _showKiloanWarning = false;
              }
            }
          });
        } else {
          throw Exception('Gagal memuat detail permintaan');
        }
      } else {
        throw Exception(
            'Gagal memuat detail permintaan: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String formatCurrency(dynamic amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount is int
            ? amount
            : double.tryParse(amount.toString())?.toInt() ?? 0);
  }

  Future<void> _updateKiloanData() async {
    // Validate input
    if (_jumlahKiloanController.text.isEmpty ||
        _hargaKiloanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah kiloan dan harga harus diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double? jumlahKiloan =
        double.tryParse(_jumlahKiloanController.text.replaceAll(',', '.'));
    double? hargaKiloan =
        double.tryParse(_hargaKiloanController.text.replaceAll(',', '.'));

    if (jumlahKiloan == null ||
        hargaKiloan == null ||
        jumlahKiloan <= 0 ||
        hargaKiloan < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah kiloan dan harga harus berupa angka valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final response = await http.post(
        Uri.parse(
            '${Apiconstant.BASE_URL}/pengusaha/transaksi/${widget.kodeTransaksi}/update-kiloan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'jumlah_kiloan': jumlahKiloan,
          'harga_kiloan': hargaKiloan,
        }),
      );

      // Close loading dialog
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data kiloan berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            _isEditingKiloan = false;
            _showKiloanWarning = false;
          });

          // Refresh data
          _fetchRequestDetail(widget.kodeTransaksi);
        } else {
          throw Exception(data['message'] ?? 'Terjadi kesalahan');
        }
      } else {
        throw Exception('Gagal memperbarui data: ${response.statusCode}');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Nota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchRequestDetail(widget.kodeTransaksi),
          ),
        ],
      ),
      body: _isLoading
          ? const _LoadingView()
          : _error != null
              ? _ErrorView(
                  error: _error!,
                  onRetry: () => _fetchRequestDetail(widget.kodeTransaksi))
              : _buildRequestDetail(),
      bottomNavigationBar:
          _isLoading || _error != null || _requestDetail == null
              ? null
              : _buildBottomActionBar(),
    );
  }

  Widget _buildBottomActionBar() {
    final status =
        _requestDetail?['status']?.toString().toLowerCase() ?? 'menunggu';

    // Check if this is a kiloan order that needs data
    final bool isKiloanOrder = _requestDetail!['id_pesanan_kiloan'] != null;
    final bool kiloanDataComplete = _requestDetail!['pesanan_kiloan'] != null &&
        _requestDetail!['pesanan_kiloan']['jumlah_kiloan'] != null &&
        _requestDetail!['pesanan_kiloan']['harga_kiloan'] != null;

    // Disable process button if kiloan data is incomplete
    final bool canProcess = !isKiloanOrder || kiloanDataComplete;

    // Status checks
    final bool isRejected = status == 'ditolak';
    final bool isProcessed = status == 'diproses';
    final bool isCompleted = status == 'selesai';
    final bool isPending = status == 'menunggu';

    // Action availability
    final bool canTakeAction = isPending; // Can only approve/reject if pending
    final bool canComplete =
        isProcessed; // Can only complete if being processed

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showKiloanWarning)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade800),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pesanan ini memerlukan data jumlah kiloan dan harga per kilo sebelum dapat diproses.',
                      style: TextStyle(color: Colors.orange.shade800),
                    ),
                  ),
                ],
              ),
            ),

          // Status info messages
          if (isRejected)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red.shade800),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pesanan ini telah ditolak dan tidak dapat diubah.',
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                ],
              ),
            ),

          if (isCompleted)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade800),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pesanan ini telah selesai.',
                      style: TextStyle(color: Colors.green.shade800),
                    ),
                  ),
                ],
              ),
            ),

          if (isProcessed)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_empty, color: Colors.blue.shade800),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pesanan sedang diproses. Klik "Selesaikan" jika pesanan sudah selesai.',
                      style: TextStyle(color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
            ),

          // Action buttons
          if (canTakeAction)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showRejectionDialog();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        canProcess ? () => _processRequest('proses') : null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Proses'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

          // Complete button for processed orders
          if (canComplete)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _completeOrder,
                icon: const Icon(Icons.done_all),
                label: const Text('Selesaikan Pesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  } 

  void _showRejectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Permintaan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Berikan alasan penolakan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rejectionReasonController,
              decoration: InputDecoration(
                hintText: 'Masukkan alasan penolakan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _rejectionReasonController.clear();
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (_rejectionReasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan penolakan harus diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _processRequest('tolak', _rejectionReasonController.text.trim());
            },
            child: const Text('Tolak'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processRequest(String action, [String? rejectionReason]) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final Map<String, dynamic> requestBody = {};

      // Add rejection reason if provided
      if (action == 'tolak' && rejectionReason != null) {
        requestBody['alasan_penolakan'] = rejectionReason;
      }

      final response = await http.post(
        Uri.parse(
            '${Apiconstant.BASE_URL}/pengusaha/transaksi/${widget.kodeTransaksi}/$action'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: requestBody.isNotEmpty ? jsonEncode(requestBody) : null,
      );

      // Close loading dialog
      Navigator.pop(context);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'proses'
                ? 'Permintaan berhasil diproses'
                : 'Permintaan berhasil ditolak'),
            backgroundColor: action == 'proses' ? Colors.green : Colors.red,
          ),
        );

        // Clear rejection reason
        _rejectionReasonController.clear();

        // Refresh data
        _fetchRequestDetail(widget.kodeTransaksi);
      } else if (response.statusCode == 422 &&
          data['requires_kiloan_data'] == true) {
        // Show kiloan data required message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Pesanan kiloan harus diisi jumlah dan harga per kilo sebelum diproses'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );

        setState(() {
          _showKiloanWarning = true;
          _isEditingKiloan = true;
        });
      } else {
        throw Exception(data['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeOrder() async {
    // Show confirmation dialog first
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Pesanan'),
        content:
            const Text('Apakah Anda yakin ingin menyelesaikan pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Selesaikan'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final response = await http.post(
        Uri.parse(
            '${Apiconstant.BASE_URL}/pengusaha/transaksi/${widget.kodeTransaksi}/selesai'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      // Close loading dialog
      Navigator.pop(context);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil diselesaikan'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh data
        _fetchRequestDetail(widget.kodeTransaksi);
      } else {
        throw Exception(data['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildRequestDetail() {
    final order = _requestDetail!;
    final toko = order['toko'];
    final items = order['items'];
    final layananTambahan = order['layanan_tambahan'];
    final pesananKiloan = order['pesanan_kiloan'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kode Transaksi',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order['kode_transaksi'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(order['status'] ?? 'Menunggu'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        order['waktu'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Rejection Reason Card (if status is rejected)
          if (order['status']?.toString().toLowerCase() == 'ditolak' &&
              order['alasan_penolakan'] != null)
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cancel_outlined, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Alasan Penolakan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      order['alasan_penolakan'] ??
                          'Tidak ada alasan yang diberikan',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

          // Toko Info Card
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.store, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Informasi Toko',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.business, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          toko['nama'],
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        toko['kontak'],
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Items Card
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_laundry_service, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Layanan Laundry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.local_laundry_service,
                                color: Colors.blue, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['produk'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${formatCurrency(item['harga'])} × ${item['quantity']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatCurrency(item['subtotal']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Pesanan Kiloan Card
          if (pesananKiloan != null &&
              pesananKiloan['details'] != null &&
              pesananKiloan['details'].isNotEmpty)
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.scale, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Pesanan Kiloan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Edit button for kiloan data - only show if status is "menunggu"
                        if (order['status']?.toString().toLowerCase() ==
                            'menunggu')
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isEditingKiloan = !_isEditingKiloan;
                              });
                            },
                            icon: Icon(
                                _isEditingKiloan ? Icons.close : Icons.edit),
                            label: Text(_isEditingKiloan ? 'Batal' : 'Edit'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Berat & Harga per kilo
                    if (_isEditingKiloan)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jumlah Kiloan (kg)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _jumlahKiloanController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              hintText: 'Masukkan jumlah kiloan',
                              suffixText: 'kg',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Harga per Kilo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _hargaKiloanController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              hintText: 'Masukkan harga per kilo',
                              prefixText: 'Rp ',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _updateKiloanData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Simpan'),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Jumlah Kiloan'),
                              Text(
                                pesananKiloan['jumlah_kiloan'] != null
                                    ? '${pesananKiloan['jumlah_kiloan']} Kg'
                                    : 'Belum ditentukan',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Harga per Kilo'),
                              Text(
                                pesananKiloan['harga_kiloan'] != null
                                    ? formatCurrency(
                                        pesananKiloan['harga_kiloan'])
                                    : 'Belum ditentukan',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          if (pesananKiloan['total_kiloan'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Kiloan'),
                                  Text(
                                    formatCurrency(
                                        pesananKiloan['total_kiloan']),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 16),

                    const Text(
                      'Detail Barang',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: pesananKiloan['details'].length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final detail = pesananKiloan['details'][index];
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.category,
                                  color: Colors.purple),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                detail['nama_barang'] ?? 'Barang',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Text(
                              'x${detail['quantity']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Layanan Tambahan Card
          if (layananTambahan.isNotEmpty)
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Layanan Tambahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: layananTambahan.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final layanan = layananTambahan[index];
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_circle,
                                  color: Colors.green, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                layanan['nama'],
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Text(
                              formatCurrency(layanan['harga']),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Summary Card
          Card(
            elevation: 2,
            color: Colors.blue.shade50,
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Produk'),
                      Text(formatCurrency(order['total_produk'])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Layanan'),
                      Text(formatCurrency(order['total_layanan'])),
                    ],
                  ),
                  if (order['total_kiloan'] != null &&
                      order['total_kiloan'] > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Kiloan'),
                          Text(formatCurrency(order['total_kiloan'])),
                        ],
                      ),
                    ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grand Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        formatCurrency(order['grand_total']),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'selesai':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'diproses':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'ditolak':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          4,
          (index) => Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
