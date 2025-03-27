import 'package:flutter/material.dart';
import 'package:carilaundry2/pages/order_menu.dart';

class ClothingItem extends StatelessWidget {
  final ClothingItemData data;
  final Function(String, int) onQuantityChanged;

  const ClothingItem({
    super.key,
    required this.data,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Item image placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          
          // Item name
          Expanded(
            child: Text(
              data.name,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          
          // Item price
          Text(
            'Rp${data.price}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          
          // Quantity controls
          Row(
            children: [
              // Decrease button
              InkWell(
                onTap: () {
                  if (data.quantity > 0) {
                    onQuantityChanged(data.name, data.quantity - 1);
                  }
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.remove, size: 16),
                ),
              ),
              
              // Quantity display
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                child: Text(
                  data.quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              
              // Increase button
              InkWell(
                onTap: () {
                  onQuantityChanged(data.name, data.quantity + 1);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.add, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

