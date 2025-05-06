// This is likely what the ServiceSection widget looks like
// Check if it properly handles the produkItems list being empty

import 'package:flutter/material.dart';
import 'package:carilaundry2/models/produk.dart';

class ServiceSection extends StatefulWidget {
  final String title;
  final String initialServiceType;
  final List<String> serviceTypes;
  final List<Produk> produkItems;
  final Function(String, int) onQuantityChanged;
  final Function(String) onServiceTypeChanged;
  final bool showItemPrices;
  final bool showSubtotal;
  final bool isPriced;

  const ServiceSection({
    Key? key,
    required this.title,
    required this.initialServiceType,
    required this.serviceTypes,
    required this.produkItems,
    required this.onQuantityChanged,
    required this.onServiceTypeChanged,
    this.showItemPrices = true,
    this.showSubtotal = true,
    this.isPriced = true,
  }) : super(key: key);

  @override
  State<ServiceSection> createState() => _ServiceSectionState();
}

class _ServiceSectionState extends State<ServiceSection> {
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialServiceType;
  }

  int get _subtotal {
    if (!widget.isPriced) return 0;
    return widget.produkItems.fold(
        0, (sum, item) => sum + (item.harga * (item.quantity ?? 0)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.serviceTypes.length > 1)
                DropdownButton<String>(
                  value: _selectedType,
                  items: widget.serviceTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                      widget.onServiceTypeChanged(value);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Display error if no products
          if (widget.produkItems.isEmpty)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No products found for this category. Check API response or kategori_id mapping.',
                      style: TextStyle(color: Colors.red[900]),
                    ),
                  ),
                ],
              ),
            ),

          // Product items
          ...widget.produkItems.map((produk) => _buildProductItem(produk)),

          // Subtotal
          if (widget.showSubtotal && widget.produkItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Subtotal: '),
                  Text('Rp$_subtotal'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Produk produk) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produk.nama,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (widget.showItemPrices)
                  Text(
                    'Rp${produk.harga}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Minus button
                InkWell(
                  onTap: () {
                    final newQuantity = (produk.quantity ?? 0) - 1;
                    if (newQuantity >= 0) {
                      widget.onQuantityChanged(produk.id, newQuantity);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Icon(Icons.remove, size: 16),
                  ),
                ),
                // Quantity display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('${produk.quantity ?? 0}'),
                ),
                // Plus button
                InkWell(
                  onTap: () {
                    final newQuantity = (produk.quantity ?? 0) + 1;
                    widget.onQuantityChanged(produk.id, newQuantity);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Icon(Icons.add, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}