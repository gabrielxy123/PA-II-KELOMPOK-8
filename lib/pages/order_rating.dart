import 'dart:convert';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderReviewPage extends StatefulWidget {
  final String laundryName;
  final String kodeTransaksi;
  final int? tokoId;

  const OrderReviewPage({
    super.key,
    required this.laundryName,
    required this.kodeTransaksi,
    this.tokoId,
  });

  @override
  _OrderReviewPageState createState() => _OrderReviewPageState();
}

class _OrderReviewPageState extends State<OrderReviewPage> {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isLoading = false;
  bool _canReview = false;
  bool _hasReview = false;
  bool _isCheckingReview = true;
  String _debugMessage = '';

  // API Base URL - sesuaikan dengan URL backend Anda
    final String baseUrl = Apiconstant.BASE_URL;
// Ganti dengan URL Anda

  @override
  void initState() {
    super.initState();
    _checkCanReview();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // Check if user can review this transaction
  Future<void> _checkCanReview() async {
    setState(() {
      _isCheckingReview = true;
      _debugMessage = 'Mengecek status ulasan...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      print('=== DEBUG CHECK CAN REVIEW ===');
      print('Token: ${token != null ? "Available (${token?.substring(0, 20)}...)" : "Not found"}');
      print('Kode Transaksi: ${widget.kodeTransaksi}');
      
      final url = '$baseUrl/ulasan/transaksi/${widget.kodeTransaksi}/cek-bisa-ulas';
      print('URL: $url');

      if (token == null) {
        setState(() {
          _debugMessage = 'Token tidak ditemukan';
        });
        _showErrorDialog('Token tidak ditemukan. Silakan login kembali.');
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - periksa koneksi internet');
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      // Handle different status codes
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('Parsed Data: $data');
          
          // Check if response has expected structure
          if (data is Map<String, dynamic>) {
            setState(() {
              _canReview = data['can_review'] ?? false;
              _hasReview = data['has_review'] ?? false;
              _isCheckingReview = false;
              _debugMessage = data['message'] ?? 'Status berhasil dicek';
            });

            print('Can Review: $_canReview');
            print('Has Review: $_hasReview');
            print('Message: ${data['message']}');

            if (_hasReview) {
              _getExistingReview();
            }
          } else {
            throw Exception('Response format tidak valid: ${data.runtimeType}');
          }
        } catch (jsonError) {
          print('JSON Parse Error: $jsonError');
          throw Exception('Gagal parsing response: $jsonError');
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _debugMessage = 'Token tidak valid atau expired';
        });
        throw Exception('Token tidak valid. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        setState(() {
          _debugMessage = 'Transaksi tidak ditemukan';
        });
        throw Exception('Transaksi tidak ditemukan atau bukan milik Anda.');
      } else {
        print('Error Response Body: ${response.body}');
        setState(() {
          _debugMessage = 'Server error: ${response.statusCode}';
        });
        
        // Try to parse error message from response
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Server error: ${response.statusCode}');
        } catch (e) {
          throw Exception('Server error: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('Exception in _checkCanReview: $e');
      setState(() {
        _isCheckingReview = false;
        _debugMessage = 'Error: $e';
      });
      
      // Show more specific error messages
      String errorMessage = e.toString();
      if (errorMessage.contains('SocketException') || errorMessage.contains('timeout')) {
        errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      } else if (errorMessage.contains('FormatException')) {
        errorMessage = 'Response server tidak valid. Hubungi administrator.';
      }
      
      _showErrorDialog(errorMessage);
    }
  }

  // Get existing review if user already reviewed
  Future<void> _getExistingReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/ulasan/transaksi/${widget.kodeTransaksi}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Get existing review status: ${response.statusCode}');
      print('Get existing review body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final review = data['data'];
          
          setState(() {
            _rating = (review['rating'] ?? 0).toDouble();
            _reviewController.text = review['review'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error getting existing review: $e');
    }
  }

  // Submit review to backend
  Future<void> _submitReview() async {
    if (_rating == 0) {
      _showErrorDialog('Silakan berikan rating terlebih dahulu');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final requestBody = {
        'kode_transaksi': widget.kodeTransaksi,
        'rating': _rating.toInt(),
        'review': _reviewController.text.trim().isEmpty 
            ? null 
            : _reviewController.text.trim(),
      };

      print('Submit review request body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/ulasan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Submit review status: ${response.statusCode}');
      print('Submit review body: ${response.body}');

      setState(() {
        _isLoading = false;
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        _showSuccessDialog('Penilaian Anda telah dikirim!');
      } else {
        throw Exception(data['message'] ?? 'Terjadi kesalahan saat mengirim ulasan');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Submit review error: $e');
      _showErrorDialog('Terjadi kesalahan: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text('Debug Info:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_debugMessage, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkCanReview(); // Retry
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Berhasil'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous page
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Pesanan'),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isCheckingReview
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_debugMessage),
                ],
              ),
            )
          : _buildReviewForm(),
    );
  }

  Widget _buildReviewForm() {
    if (!_canReview && !_hasReview) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak Dapat Memberikan Ulasan',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _debugMessage,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _checkCanReview,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Rest of the form code remains the same...
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.laundryName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.receipt,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kode Transaksi: ${widget.kodeTransaksi}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Rating Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hasReview ? 'Kualitas Layanan' : 'Beri Penilaian',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: _hasReview ? null : () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  if (_rating > 0)
                    Center(
                      child: Text(
                        '${_rating.toInt()} dari 5 bintang',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Review Text Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ulasan (Opsional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reviewController,
                    enabled: !_hasReview,
                    decoration: InputDecoration(
                      hintText: _hasReview 
                          ? 'Anda sudah memberikan ulasan'
                          : 'Tulis ulasan Anda tentang pelayanan laundry ini...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    maxLines: 4,
                    maxLength: 1000,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Submit Button
          if (!_hasReview)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || _rating == 0 ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Kirim Ulasan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

          // Info for existing review
          if (_hasReview)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Anda sudah memberikan ulasan untuk pesanan ini.',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}