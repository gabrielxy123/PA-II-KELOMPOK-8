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
                  _pickImage(ImageSource.gallery);
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (bagian informasi pembayaran tetap sama)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
                borderRadius: BorderRadius.circular(12),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'BANK MANDIRI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const Text(
                    '1070019483231',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const Text(
                    'A.N Odelia Josephine SIM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Bagian upload bukti
            GestureDetector(
              onTap: _showImagePicker,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: _imageFile == null
                    ? Center(
                        child: Icon(
                          LucideIcons.uploadCloud,
                          size: 48,
                          color: Colors.grey.shade500,
                        ),
                      )
                    : Image.file(_imageFile!, fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _uploadBuktiPembayaran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Kirim',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
