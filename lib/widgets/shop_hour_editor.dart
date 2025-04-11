import 'package:flutter/material.dart';

class ShopHoursEditor extends StatefulWidget {
  final String initialDays;
  final String initialHours;
  
  const ShopHoursEditor({
    super.key,
    required this.initialDays,
    required this.initialHours,
  });

  @override
  State<ShopHoursEditor> createState() => _ShopHoursEditorState();
}

class _ShopHoursEditorState extends State<ShopHoursEditor> {
  late TextEditingController _daysController;
  late TextEditingController _hoursController;
  
  @override
  void initState() {
    super.initState();
    _daysController = TextEditingController(text: widget.initialDays);
    _hoursController = TextEditingController(text: widget.initialHours);
  }
  
  @override
  void dispose() {
    _daysController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jam Operasional',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Operational days field
        const Text(
          'Hari Operasional',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _daysController,
          decoration: const InputDecoration(
            hintText: 'Contoh: Senin - Jumat',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Hari operasional tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Operational hours field
        const Text(
          'Jam Operasional',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _hoursController,
          decoration: const InputDecoration(
            hintText: 'Contoh: 08.00 - 17.00',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jam operasional tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }
}

