import 'package:flutter/material.dart';

class ShopInfoForm extends StatefulWidget {
  final String initialName;
  final String initialDescription;
  final String initialAddress;
  
  const ShopInfoForm({
    super.key,
    required this.initialName,
    required this.initialDescription,
    required this.initialAddress,
  });

  @override
  State<ShopInfoForm> createState() => _ShopInfoFormState();
}

class _ShopInfoFormState extends State<ShopInfoForm> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _addressController = TextEditingController(text: widget.initialAddress);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi Toko',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Shop name field
        const Text(
          'Nama Toko',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama toko',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama toko tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Shop description field
        const Text(
          'Deskripsi Toko',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Masukkan deskripsi toko',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Deskripsi toko tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Shop address field
        const Text(
          'Alamat',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            hintText: 'Masukkan alamat toko',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Alamat toko tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }
}
