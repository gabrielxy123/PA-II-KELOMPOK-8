import 'package:carilaundry2/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/widgets/payment_proof.dart';

class RequestListPage extends StatefulWidget {
  @override
  _RequestListPageState createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  String activeFilter = 'Menunggu';
  List<dynamic> tokoList = [];
  bool isLoading = true;
  bool isProcessing = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDataToko();
  }

  String formatDate(String? isoDate) {
    if (isoDate == null) return 'Tidak ada tanggal';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day} - ${date.month} - ${date.year}';
    } catch (e) {
      return 'Format tanggal salah';
    }
  }

  Future<void> fetchDataToko() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
  
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      print('Token: ${token.isNotEmpty ? "Ada" : "Kosong"}');

      if (token.isEmpty) {
        throw Exception('Anda belum login.');
      }

      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/index-toko'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null) {
          setState(() {
            tokoList = data['data'];
          });
        } else {
          throw Exception('Data toko tidak ditemukan.');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token tidak valid. Silakan login ulang.');
      } else {
        throw Exception('Gagal memuat data toko: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Approve toko
  Future<void> approveToko(String tokoId) async {
    setState(() {
      isProcessing = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.put(
        Uri.parse('${Apiconstant.BASE_URL}/$tokoId/approve'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Update status di local state
        setState(() {
          for (var i = 0; i < tokoList.length; i++) {
            if (tokoList[i]['id'].toString() == tokoId) {
              tokoList[i]['status'] = 'Diterima';
              break;
            }
          }
          // Pindah ke tab Diterima
          activeFilter = 'Diterima';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Toko berhasil disetujui'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(responseData['message'] ?? 'Gagal menyetujui toko');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  // Reject toko
  Future<void> rejectToko(String tokoId) async {
    setState(() {
      isProcessing = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.put(
        Uri.parse('${Apiconstant.BASE_URL}/$tokoId/reject'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Update status di local state
        setState(() {
          for (var i = 0; i < tokoList.length; i++) {
            if (tokoList[i]['id'].toString() == tokoId) {
              tokoList[i]['status'] = 'Ditolak';
              break;
            }
          }
          // Pindah ke tab Ditolak
          activeFilter = 'Ditolak';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Toko berhasil ditolak'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw Exception(responseData['message'] ?? 'Gagal menolak toko');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void updateFilter(String filter) {
    setState(() {
      activeFilter = filter;
    });
  }

  // Menampilkan dialog detail toko
  void showDetailDialog(BuildContext context, Map<String, dynamic> toko) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detail Toko'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Toko   : ${toko['nama'] ?? 'Tidak ada'}'),
                SizedBox(height: 8),
                Text('Alamat: ${toko['jalan'] ?? 'Tidak ada'}'),
                SizedBox(height: 8),
                Text('Kecamatan: ${toko['kecamatan'] ?? 'Tidak ada'}'),
                SizedBox(height: 8),
                Text('Kabupaten: ${toko['kabupaten'] ?? 'Tidak ada'}'),
                SizedBox(height: 8),
                Text('Provinsi: ${toko['provinsi'] ?? 'Tidak ada'}'),
                SizedBox(height: 8),
                Text('Waktu Buka: ${toko['waktuBuka'] ?? 'Tidak ada'}'),
                SizedBox(height: 8),
                Text('Waktu Tutup: ${toko['waktuTutup'] ?? 'Tidak ada'}'),
                SizedBox(height: 8),
                Text('Nomor Telepon: ${toko['noTelp'] ?? 'Tidak ada'}'),
                SizedBox(height: 8),
                Text('Tanggal Request: ${formatDate(toko['created_at'])}'),
                SizedBox(height: 8),
                Text('Status: ${toko['status'] ?? 'Menunggu'}'),
                SizedBox(height: 16),
                
                // Tombol untuk melihat bukti pembayaran
                if (toko['buktiBayar'] != null && toko['buktiBayar'].isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showPaymentProofDialog(context, toko);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00695C),
                      foregroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt, size: 18),
                        SizedBox(width: 8),
                        Flexible(
                        child: Text(
                          'Lihat Bukti Pembayaran', 
                          overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  )
                else
                  Text('Belum ada bukti pembayaran', 
                    style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic
                    )
                  ),
              ],
            ),
          ),
          actions: [
            // Hanya tombol Tutup, tanpa tombol Setuju dan Tolak
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // Menampilkan dialog bukti pembayaran
  void showPaymentProofDialog(BuildContext context, Map<String, dynamic> toko) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PaymentProofDialog(
          toko: toko,
          formatDate: formatDate,
          onBackToDetail: () => showDetailDialog(context, toko),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          "Keluar Akun ?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          "Apakah kamu ingin keluar dari akunmu sekarang ?",
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tidak",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/dashboard", (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00695C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              "Iya, Keluar",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 24),
        actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList =
        tokoList.where((toko) => toko['status'] == activeFilter).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Profile avatar
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.png'),
              radius: 20,
            ),
            SizedBox(width: 12),
            // User name
            Text(
              'Admin Laundry',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              _showLogoutDialog(context);    
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Filter tabs
                Row(
                  children: [
                    Expanded(
                      child: FilterButton(
                        label: 'Menunggu',
                        isActive: activeFilter == 'Menunggu',
                        onPressed: () => updateFilter('Menunggu'),
                        activeColor:
                            Color(0xFF00695C), // Dark green color from design
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: FilterButton(
                        label: 'Diterima',
                        isActive: activeFilter == 'Diterima',
                        onPressed: () => updateFilter('Diterima'),
                        activeColor: Color(0xFF00695C),
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: FilterButton(
                        label: 'Ditolak',
                        isActive: activeFilter == 'Ditolak',
                        onPressed: () => updateFilter('Ditolak'),
                        activeColor: Color(0xFF00695C),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Request list
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator(color: Color(0xFF00695C)))
                      : errorMessage.isNotEmpty
                          ? Center(
                              child: Text(
                                errorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : filteredList.isEmpty
                              ? Center(
                                  child: Text(
                                    'Tidak Ada Request Toko',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: fetchDataToko,
                                  color: Color(0xFF00695C),
                                  child: ListView.builder(
                                    itemCount: filteredList.length,
                                    itemBuilder: (context, index) {
                                      var toko = filteredList[index];
                                      return RequestCard(
                                        title: toko['nama'] ?? 'Tidak ada nama',
                                        requestDate: formatDate(toko['created_at']),
                                        name: toko['jalan'] ?? 'Tidak ada nama',
                                        address:
                                            toko['kecamatan'] ?? 'Tidak ada alamat',
                                        phone: toko['noTelp'] ??
                                            'Tidak ada nomor telepon',
                                        status: toko['status'] ?? 'Menunggu',
                                        tokoId: toko['id'].toString(),
                                        onDetailPressed: () => showDetailDialog(context, toko),
                                        // Only pass callbacks if status is "Menunggu"
                                        onApprove: toko['status'] == 'Menunggu' 
                                            ? (id) => approveToko(id) 
                                            : null,
                                        onReject: toko['status'] == 'Menunggu' 
                                            ? (id) => rejectToko(id) 
                                            : null,
                                      );
                                    },
                                  ),
                                ),
                ),
              ],
            ),
          ),
          // Overlay loading indicator saat proses update
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00695C),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// FilterButton tetap di file utama
class FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;
  final Color activeColor;

  const FilterButton({
    Key? key,
    required this.label,
    required this.isActive,
    required this.onPressed,
    this.activeColor = Colors.green,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? activeColor : Color(0xFFE0E0E0),
        foregroundColor: isActive ? Colors.white : Colors.black,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // Square corners as per design
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}

// RequestCard tetap di file utama
class RequestCard extends StatelessWidget {
  final String title;
  final String requestDate;
  final String name;
  final String address;
  final String phone;
  final String status;
  final String tokoId;
  final VoidCallback onDetailPressed;
  final Function(String)? onApprove;
  final Function(String)? onReject;

  const RequestCard({
    Key? key,
    required this.title,
    required this.requestDate,
    required this.name,
    required this.address,
    required this.phone,
    required this.status,
    required this.tokoId,
    required this.onDetailPressed,
    this.onApprove,
    this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: status == 'Menunggu'
                        ? Color(0xFF00695C)
                        : status == 'Diterima'
                            ? Colors.green
                            : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Di Request Pada $requestDate',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            // Owner info with placeholder image
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder image as shown in design
                Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey[300],
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Action buttons aligned to the right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Detail button
                SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: onDetailPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: Text(
                      'Detail',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                // Only show Approve and Reject buttons if status is "Menunggu"
                if (status == 'Menunggu') ...[
                  SizedBox(width: 8),
                  // Approve button
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onApprove != null
                          ? () async {
                              final confirmed = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Konfirmasi'),
                                  content: Text(
                                      'Anda yakin ingin menyetujui toko ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text('Setujui'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                onApprove!(tokoId);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00695C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      child: Text('Setujui'),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Reject button
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onReject != null
                          ? () async {
                              final confirmed = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Konfirmasi'),
                                  content:
                                      Text('Anda yakin ingin menolak toko ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text('Tolak'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                onReject!(tokoId);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      child: Text('Tolak'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}