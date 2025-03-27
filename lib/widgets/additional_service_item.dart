import 'package:flutter/material.dart';
import 'package:carilaundry2/pages/order_menu.dart';

class AdditionalServiceItem extends StatelessWidget {
  final AdditionalServiceData data;
  final Function(String, bool) onChanged;

  const AdditionalServiceItem({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Checkbox
          Checkbox(
            value: data.isSelected,
            activeColor: const Color(0xFF006A4E),
            onChanged: (bool? value) {
              onChanged(data.name, value ?? false);
            },
          ),
          
          // Service name
          Expanded(
            child: Text(
              data.name,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          
          // Service price
          Text(
            'Rp${data.price}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

