import 'package:flutter/material.dart';

class ShopContactEditor extends StatefulWidget {
  final String initialWhatsapp;
  final String initialFacebook;
  
  const ShopContactEditor({
    super.key,
    required this.initialWhatsapp,
    required this.initialFacebook,
  });

  @override
  State<ShopContactEditor> createState() => _ShopContactEditorState();
}

class _ShopContactEditorState extends State<ShopContactEditor> {
  late TextEditingController _whatsappController;
  late TextEditingController _facebookController;
  
  @override
  void initState() {
    super.initState();
    _whatsappController = TextEditingController(text: widget.initialWhatsapp);
    _facebookController = TextEditingController(text: widget.initialFacebook);
  }
  
  @override
  void dispose() {
    _whatsappController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kontak',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // WhatsApp field
        const Text(
          'WhatsApp',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _whatsappController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'Masukkan nomor WhatsApp',
            prefixIcon: Icon(Icons.phone),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nomor WhatsApp tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Facebook field
        const Text(
          'Facebook',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _facebookController,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama halaman Facebook',
            prefixIcon: Icon(Icons.facebook),
          ),
        ),
      ],
    );
  }
}
