import 'package:flutter/material.dart';
import '../models/menu.dart';

class ClothingItem extends StatelessWidget {
  final ClothingItemData data;
  final Function(String, int) onQuantityChanged;
  final bool showPrice;

  const ClothingItem({
    super.key,
    required this.data,
    required this.onQuantityChanged,
    this.showPrice = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Item image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              getIconForClothing(data.name),
              color: Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Item name
          Expanded(
            child: Text(
              data.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Item price (conditional)
          if (showPrice) ...[
            Text(
              'Rp${data.price.toString()}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
          ],
          
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
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.remove, size: 14),
                ),
              ),
              
              // Quantity display
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                child: Text(
                  data.quantity.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              
              // Increase button
              InkWell(
                onTap: () {
                  onQuantityChanged(data.name, data.quantity + 1);
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.add, size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData getIconForClothing(String name) {
    switch (name.toLowerCase()) {
      case 'kaos':
        return Icons.dry_cleaning;
      case 'kemeja':
        return Icons.dry_cleaning;
      case 'celana':
        return Icons.dry_cleaning;
      default:
        return Icons.dry_cleaning;
    }
  }
}
