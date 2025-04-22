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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/logo.png'),
              radius: 16,
            ),
            SizedBox(width: 10),
            Text(
              'Budi Santoso',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.normal,
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
      body: Padding(
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
                    activeColor: Color(0xFF00796B), // Dark teal color
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: FilterButton(
                    label: 'Diterima',
                    isActive: activeFilter == 'Diterima',
                    onPressed: () => updateFilter('Diterima'),
                    activeColor: Color(0xFF00796B),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: FilterButton(
                    label: 'Ditolak',
                    isActive: activeFilter == 'Ditolak',
                    onPressed: () => updateFilter('Ditolak'),
                    activeColor: Color(0xFF00796B),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Request list
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Color(0xFF00796B)))
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
                                  address: toko['jalan'] ?? 'Tidak ada alamat',
                                  phone: toko['noTelp'] ?? 'Tidak ada nomor telepon',
                                  status: toko['status'] ?? 'Menunggu',
                                  onDetailPressed: () => showDetailDialog(context, toko),
                                );
                              },
                            ),
            ),
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
              backgroundColor: Color(0xFF00796B),
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
  final Color activeColor;

  const FilterButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
    this.activeColor = Colors.green,
  });

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
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
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
  final VoidCallback onDetailPressed;

  const RequestCard({
    required this.title,
    required this.requestDate,
    required this.name,
    required this.address,
    required this.phone,
    required this.status,
    required this.onDetailPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
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
                        ? Color(0xFF00796B) 
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
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: onDetailPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 12),
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
                SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00796B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: Text(
                      'Setuju',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: Text(
                      'Tolak',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}