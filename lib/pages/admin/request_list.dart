import 'package:carilaundry2/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carilaundry2/core/apiConstant.dart';

class RequestListPage extends StatefulWidget {
  @override
  _RequestListPageState createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  String activeFilter = 'Menunggu';
  List<dynamic> tokoList = [];
  bool isLoading = true;
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
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        fetchDataToko(); // Refresh data
      } else {
        throw Exception(responseData['message'] ?? 'Gagal menyetujui toko');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

// Reject toko
  Future<void> rejectToko(String tokoId) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        fetchDataToko(); // Refresh data
      } else {
        throw Exception(responseData['message'] ?? 'Gagal menolak toko');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void updateFilter(String filter) {
    setState(() {
      activeFilter = filter;
    });
  }

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
                Text('Waktu Buka: ${toko['waktuBuka'] ?? 'Tidak ada'}'),
                SizedBox(height: 8),
                Text('Waktu Tutup: ${toko['waktuTutup'] ?? 'Tidak ada'}'),
                SizedBox(height: 8),
                Text('Nomor Telepon: ${toko['noTelp'] ?? 'Tidak ada'}'),
                SizedBox(height: 8),
                Text('Tanggal Request: ${formatDate(toko['created_at'])}'),
                SizedBox(height: 8),
                Text('Status: ${toko['status'] ?? 'Menunggu'}'),
                SizedBox(height: 8),
                if (toko['buktiBayar'] != null && toko['buktiBayar'].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bukti Pembayaran:'),
                      SizedBox(height: 8),
                      Image.network(
                        '${Apiconstant.BASE_URL}${toko['buktiBayar']}',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, StackTrace) {
                          return Text('Gagal Memuat Gambar');
                        },
                      )
                    ],
                  ),
                Text('Belum ada bukti pembayaran')
              ],
            ),
          ),
          actions: [
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

  @override
  Widget build(BuildContext context) {
    final filteredList =
        tokoList.where((toko) => toko['status'] == activeFilter).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),
            SizedBox(width: 10),
            Text('ADMIN DASHBOARD'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Tambahkan logika logout di sini
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterButton(
                    label: 'Menunggu',
                    isActive: activeFilter == 'Menunggu',
                    onPressed: () => updateFilter('Menunggu'),
                  ),
                  SizedBox(width: 8),
                  FilterButton(
                    label: 'Diterima',
                    isActive: activeFilter == 'Diterima',
                    onPressed: () => updateFilter('Diterima'),
                  ),
                  SizedBox(width: 8),
                  FilterButton(
                    label: 'Ditolak',
                    isActive: activeFilter == 'Ditolak',
                    onPressed: () => updateFilter('Ditolak'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
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
                                  'Tidak ada data untuk filter "$activeFilter"',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  var toko = filteredList[index];
                                  return RequestCard(
                                    title: toko['nama'] ?? 'Tidak ada nama',
                                    requestDate: formatDate(toko['created_at']),
                                    name: toko['nama'] ?? 'Tidak ada nama',
                                    address:
                                        toko['jalan'] ?? 'Tidak ada alamat',
                                    phone: toko['noTelp'] ??
                                        'Tidak ada nomor telepon',
                                    status: toko['status'] ?? 'Menunggu',
                                    tokoId:
                                        toko['id'].toString(), // Tambahkan ini
                                    onDetailPressed: () =>
                                        showDetailDialog(context, toko),
                                    onApprove: (id) =>
                                        approveToko(id), // Tambahkan ini
                                    onReject: (id) =>
                                        rejectToko(id), // Tambahkan ini
                                  );
                                },
                              )),
          ],
        ),
      ),
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
              backgroundColor: Constants.primaryColor,
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
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const FilterButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.green : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(label),
    );
  }
}

class RequestCard extends StatelessWidget {
  final String title;
  final String requestDate;
  final String name;
  final String address;
  final String phone;
  final String status;
  final String tokoId; // Tambahkan ini
  final VoidCallback onDetailPressed;
  final Function(String) onApprove; // Tambahkan ini
  final Function(String) onReject; // Tambahkan ini

  const RequestCard({
    required this.title,
    required this.requestDate,
    required this.name,
    required this.address,
    required this.phone,
    required this.status,
    required this.tokoId, // Tambahkan ini
    required this.onDetailPressed,
    required this.onApprove, // Tambahkan ini
    required this.onReject, // Tambahkan ini
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case 'Diterima':
        statusColor = Colors.green;
        break;
      case 'Ditolak':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4.0,
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
                  style: TextStyle(color: statusColor),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Di Request Pada $requestDate'),
            SizedBox(height: 8),
            Text(name),
            Text(address),
            Text(phone),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onDetailPressed,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text('Detail'),
                ),
                ElevatedButton(
                  onPressed: status == 'Menunggu'
                      ? () async {
                          final confirmed = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Konfirmasi'),
                              content:
                                  Text('Anda yakin ingin menyetujui toko ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Setujui'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            onApprove(tokoId);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Setujui'),
                ),
                ElevatedButton(
                  onPressed: status == 'Menunggu'
                      ? () async {
                          final alasan = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Konfirmasi'),
                              content: Text('Anda yakin ingin menolak toko ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Tolak')
                                ),
                              ],
                            ),
                          );

                          if (alasan == true) {
                            onReject(tokoId);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Tolak'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
