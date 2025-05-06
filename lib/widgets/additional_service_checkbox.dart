import 'package:flutter/material.dart';

class AdditionalServiceCheckbox extends StatelessWidget {
  final String name;
  final int price;
  final bool isSelected;
  final Function(bool) onChanged;

  const AdditionalServiceCheckbox({
    super.key,
    required this.name,
    required this.price,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isSelected,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
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
            name,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          'Rp$price',
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