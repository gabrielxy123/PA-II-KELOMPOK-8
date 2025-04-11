import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/service_type.dart';
import 'package:carilaundry2/widgets/clothing_item.dart';
import 'package:carilaundry2/widgets/additional_service_item.dart';
import 'package:carilaundry2/widgets/bottom_navigation.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  // Initial values for clothing items
  final Map<String, ClothingItemData> clothingItems = {
    'Kaos': ClothingItemData(name: 'Kaos', price: 7000, quantity: 3),
    'Kemeja': ClothingItemData(name: 'Kemeja', price: 8000, quantity: 2),
    'Celana': ClothingItemData(name: 'Celana', price: 10000, quantity: 4),
  };

  // Additional services
  final Map<String, AdditionalServiceData> additionalServices = {
    'Extra Pelembut': AdditionalServiceData(
        name: 'Extra Pelembut', price: 5000, isSelected: true),
    'Lipatan spesial': AdditionalServiceData(
        name: 'Lipatan spesial', price: 3000, isSelected: true),
  };

  // Calculate subtotal for clothing items
  int get clothingSubtotal {
    int total = 0;
    for (var item in clothingItems.values) {
      total += item.price * item.quantity;
    }
    return total;
  }

  // Calculate subtotal for additional services
  int get additionalServicesSubtotal {
    int total = 0;
    for (var service in additionalServices.values) {
      if (service.isSelected) {
        total += service.price;
      }
    }
    return total;
  }

  // Calculate total
  int get total => clothingSubtotal + additionalServicesSubtotal;

  void updateClothingQuantity(String name, int newQuantity) {
    setState(() {
      if (clothingItems.containsKey(name)) {
        clothingItems[name]!.quantity = newQuantity;
      }
    });
  }

  void toggleAdditionalService(String name, bool value) {
    setState(() {
      if (additionalServices.containsKey(name)) {
        additionalServices[name]!.isSelected = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan Laundry'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content with scrolling
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Detail Layanan section
                    const Text(
                      'Detail Layanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const ServiceTypeDropdown(),
                    const SizedBox(height: 24),

                    // List Pakaian section
                    const Text(
                      'List Pakaian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Clothing items list
                    ...clothingItems.values.map((item) => ClothingItem(
                          data: item,
                          onQuantityChanged: updateClothingQuantity,
                        )),

                    // Clothing subtotal
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'Subtotal: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rp${clothingSubtotal.toString()}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Additional services
                    ...additionalServices.entries
                        .map((entry) => AdditionalServiceItem(
                              data: entry.value,
                              onChanged: toggleAdditionalService,
                            )),

                    // Additional services subtotal
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'Subtotal: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rp${additionalServicesSubtotal.toString()}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp${total.toString()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006A4E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notes field
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Catatan',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Create note button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle create note button press
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006A4E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Pesan Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom navigation
            // const BottomNavigationBarWidget(),
          ],
        ),
      ),
    );
  }
}

// Data classes
class ClothingItemData {
  final String name;
  final int price;
  int quantity;

  ClothingItemData({
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class AdditionalServiceData {
  final String name;
  final int price;
  bool isSelected;

  AdditionalServiceData({
    required this.name,
    required this.price,
    required this.isSelected,
  });
}
