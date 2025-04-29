import 'package:flutter/material.dart';
import '../models/menu.dart';

class AdditionalServiceCheckbox extends StatelessWidget {
  final AdditionalServiceData data;
  final Function(String, bool) onChanged;

  const AdditionalServiceCheckbox({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: data.isSelected,
          onChanged: (value) {
            if (value != null) {
              onChanged(data.name, value);
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: BorderSide(color: Colors.grey.shade400),
          activeColor: const Color(0xFF006A4E),
        ),
        Expanded(
          child: Text(
            data.name,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          'Rp${data.price.toString()}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
