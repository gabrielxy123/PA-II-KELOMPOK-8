import 'package:flutter/material.dart';
import '../models/menu.dart';
import 'clothing_item.dart';

class ServiceSection extends StatefulWidget {
  final String title;
  final String initialServiceType;
  final List<String> serviceTypes;
  final List<ClothingItemData> clothingItems;
  final Function(String, int) onQuantityChanged;
  final Function(String) onServiceTypeChanged;
  final bool showItemPrices;
  final bool showSubtotal;
  final bool isPriced; // New parameter to indicate if this section has pricing

  const ServiceSection({
    super.key,
    required this.title,
    required this.initialServiceType,
    required this.serviceTypes,
    required this.clothingItems,
    required this.onQuantityChanged,
    required this.onServiceTypeChanged,
    this.showItemPrices = true,
    this.showSubtotal = true,
    this.isPriced = true, // Default to having pricing
  });

  @override
  State<ServiceSection> createState() => _ServiceSectionState();
}

class _ServiceSectionState extends State<ServiceSection> {
  late String selectedServiceType;
  bool isExpanded = true;

  @override
  void initState() {
    super.initState();
    selectedServiceType = widget.initialServiceType;
  }

  // Calculate subtotal for this section
  int get subtotal {
    // Skip calculation if this section doesn't have pricing
    if (!widget.isPriced) {
      return 0;
    }
    
    // Calculate based on individual prices
    int total = 0;
    for (var item in widget.clothingItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Service type dropdown
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedServiceType,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.grey.shade700,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Clothing items list (only if expanded)
        if (isExpanded) ...[
          ...widget.clothingItems.map((item) => ClothingItem(
                data: item,
                onQuantityChanged: widget.onQuantityChanged,
                showPrice: widget.showItemPrices && widget.isPriced,
              )),

          // Subtotal (only if showSubtotal is true and section has pricing)
          if (widget.showSubtotal && widget.isPriced) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Subtotal: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Rp ${subtotal.toString()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const Divider(thickness: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
