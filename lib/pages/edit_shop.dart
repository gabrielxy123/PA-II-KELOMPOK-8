import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/shop_logo_editor.dart';
import 'package:carilaundry2/widgets/shop_info_edit.dart';
import 'package:carilaundry2/widgets/shop_hour_editor.dart';
import 'package:carilaundry2/widgets/shop_contact_editor.dart';

class EditShopScreen extends StatefulWidget {
  const EditShopScreen({super.key});

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Initial shop data (would come from API/database in a real app)
  final Map<String, dynamic> shopData = {
    'name': 'LAUNDRY FANYA',
    'description': '"Bersih, Wangi, dan Rapi!" - Kami hadir untuk memberikan layanan laundry terbaik dengan hasil yang bersih, harum, dan rapi. Dari cuci biasa hingga setrika, kami siap membantu Anda menghemat waktu dan tenaga. Dengan layanan cepat dan harga terjangkau, pakaian Anda akan kembali segar seperti baru!',
    'address': 'Jl. Balige - Tanjung No. 200',
    'operationalDays': 'Senin - Jumat',
    'operationalHours': '08.00 - 17.00',
    'whatsapp': '081234567890',
    'facebook': 'Laundry Fanya',
  };

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // In a real app, you would save the data to a database or API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan berhasil disimpan'),
          backgroundColor: Color(0xFF006A4E),
        ),
      );
      
      // Navigate back or to shop profile page
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil Toko'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: Color(0xFF006A4E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop logo editor
                ShopLogoEditor(initialLogo: shopData['logo']),
                const SizedBox(height: 24),
                
                // Shop info form (name, description, address)
                ShopInfoForm(
                  initialName: shopData['name'],
                  initialDescription: shopData['description'],
                  initialAddress: shopData['address'],
                ),
                const SizedBox(height: 24),
                
                // Shop hours editor
                ShopHoursEditor(
                  initialDays: shopData['operationalDays'],
                  initialHours: shopData['operationalHours'],
                ),
                const SizedBox(height: 24),
                
                // Shop contact editor
                ShopContactEditor(
                  initialWhatsapp: shopData['whatsapp'],
                  initialFacebook: shopData['facebook'],
                ),
                const SizedBox(height: 32),
                
                // Save button at the bottom
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
