import 'dart:convert';
import 'dart:io';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:carilaundry2/main.dart';

class UploadPembayaran extends StatefulWidget {
  const UploadPembayaran({super.key});

  @override
  State<UploadPembayaran> createState() => _UploadPembayaranState();
}

class _UploadPembayaranState extends State<UploadPembayaran> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Fungsi untuk mendapatkan token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Add these methods to the _UploadPembayaranState class

// Add this to the initState method
  @override
  void initState() {
    super.initState();
    _loadTokoData();
  }

// Add a variable to store toko data
  Map<String, dynamic>? tokoData;

// Add this method to load toko data
  Future<void> _loadTokoData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('toko_data');

      if (storedData != null && storedData.isNotEmpty) {
        setState(() {
          tokoData = json.decode(storedData);
        });
        print('Loaded toko data: $tokoData');
      } else {
        // If no stored data, fetch from API
        await _fetchTokoData();
      }
    } catch (e) {
      print('Error loading toko data: $e');
    }
  }

// Add this method to fetch toko data from API if needed
  Future<void> _fetchTokoData() async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        _showSnackBar('Anda belum login', Colors.red);
        return;
      }

      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/toko-saya'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 403) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            tokoData = data['data'];
          });

          // Store for future use
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('toko_data', json.encode(tokoData));
        }
      }
    } catch (e) {
      print('Error fetching toko data: $e');
    }
  }

  // Fungsi untuk upload bukti pembayaran
  Future<void> _uploadBuktiPembayaran() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Harap pilih bukti pembayaran terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Apiconstant.BASE_URL}/upload-bukti-bayar'),
      );

      // Tambahkan headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add toko_id if available
      if (tokoData != null && tokoData!['id'] != null) {
        request.fields['toko_id'] = tokoData!['id'].toString();
      }

      // Tambahkan file
      request.files.add(
        await http.MultipartFile.fromPath(
          'buktiBayar',
          _imageFile!.path,
          filename: path.basename(_imageFile!.path),
        ),
      );

      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      final responseData = jsonDecode(respStr);

      if (response.statusCode == 200) {
        // Berhasil upload
        _showSnackBar(
            "Bukti pembayaran berhasil diupload. Silahkan tunggu persetujuan admin",
            Colors.green);

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(
              context, "/dashboard"); // Ganti dengan route tujuan
        }
      } else {
        // Gagal upload
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal upload: ${jsonDecode(respStr)['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading:
                    Icon(Icons.photo_camera, color: Constants.primaryColor),
                title: Text('Ambil Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.photo_library, color: Constants.primaryColor),
                title: Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    // Clear any existing SnackBars
    rootScaffoldMessengerKey.currentState?.clearSnackBars();

    // Show the new SnackBar with fixed behavior
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Fungsi untuk memilih gambar
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 500,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar('Error memilih gambar: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Bukti Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/user-profil'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and instructions
              const Text(
                'Informasi Pembayaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Silahkan transfer sesuai dengan informasi di bawah ini dan upload bukti pembayaran Anda.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Payment information card - Center the card
              Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade700,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'Rp 100.000,00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white30, thickness: 1),
                      const SizedBox(height: 20),
                      const Text(
                        'Informasi Rekening',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Icons.account_balance,
                              color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'BANK MANDIRI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.credit_card,
                              color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            '1070019483231',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.person, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'A.N Odelia Josephine SIM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Upload section title
              const Text(
                'Upload Bukti Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pastikan bukti pembayaran terlihat jelas dan lengkap',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Upload area - Match the width and center like the payment card
              Center(
                child: GestureDetector(
                  onTap: _showImagePicker,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 450),
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _imageFile == null
                            ? Colors.grey.shade300
                            : Colors.teal.shade700,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.uploadCloud,
                                size: 64,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tap untuk memilih bukti pembayaran',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.teal),
                                    onPressed: _showImagePicker,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Submit button - Match the width and center like other elements
              Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 450),
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _uploadBuktiPembayaran,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Kirim Bukti Pembayaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
