import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/service_type.dart';
import 'package:carilaundry2/widgets/clothing_item.dart';
import 'package:carilaundry2/widgets/additional_service_item.dart';
import 'package:carilaundry2/widgets/bottom_navigation.dart';
import 'package:carilaundry2/widgets/service_section.dart';
import 'package:carilaundry2/widgets/additional_service_checkbox.dart';
import 'package:carilaundry2/models/menu.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  // Service sections data
  final Map<String, List<ClothingItemData>> serviceSections = {
    'Jenis Layanan 1': [
      ClothingItemData(name: 'Kaos', price: 0, quantity: 0),
      ClothingItemData(name: 'Kemeja', price: 0, quantity: 0),
      ClothingItemData(name: 'Celana', price: 0, quantity: 0),
    ],
    'Jenis Layanan 2': [
      ClothingItemData(name: 'Selimut', price: 7000, quantity: 0),
      ClothingItemData(name: 'Sprei', price: 8000, quantity: 0),
      ClothingItemData(name: 'Sepatu', price: 10000, quantity: 0),
    ],
  };
  
  // Service types and pricing
  final Map<String, String> selectedServiceTypes = {
    'Jenis Layanan 1': 'Laundry Kiloan',
    'Jenis Layanan 2': 'Laundry Satuan',
  };
  
  // Additional services
  final List<AdditionalServiceData> additionalServices = [
    AdditionalServiceData(name: 'Extra Pelembut', price: 5000, isSelected: false),
    AdditionalServiceData(name: 'Extra Pewangi', price: 3000, isSelected: false),
  ];
  
  // Calculate subtotal for clothing items in a section
  int getSubtotalForSection(String section) {
    // Skip calculation for Layanan 1 (Laundry Kiloan)
    if (section == 'Jenis Layanan 1') {
      return 0; // Laundry Kiloan doesn't have a price calculation
    } else {
      // For Layanan 2, calculate based on individual prices
      int total = 0;
      for (var item in serviceSections[section]!) {
        total += item.price * item.quantity;
      }
      return total;
    }
  }
  
  // Calculate subtotal for additional services
  int get additionalServicesSubtotal {
    int total = 0;
    for (var service in additionalServices) {
      if (service.isSelected) {
        total += service.price;
      }
    }
    return total;
  }
  
  // Calculate total
  int get total {
    // Only include Layanan 2 in the total calculation
    int sum = getSubtotalForSection('Jenis Layanan 2');
    sum += additionalServicesSubtotal;
    return sum;
  }

  void updateClothingQuantity(String section, String name, int newQuantity) {
    setState(() {
      final items = serviceSections[section]!;
      final index = items.indexWhere((item) => item.name == name);
      if (index != -1) {
        items[index].quantity = newQuantity;
      }
    });
  }

  void updateServiceType(String section, String newType) {
    setState(() {
      selectedServiceTypes[section] = newType;
    });
  }

  void toggleAdditionalService(String name, bool value) {
    setState(() {
      final index = additionalServices.indexWhere((service) => service.name == name);
      if (index != -1) {
        additionalServices[index].isSelected = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laundry Agian'),
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
                    const Text(
                      'Detail Pesanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Service section 1 (Kilogram-based, no prices or calculations)
                    ServiceSection(
                      title: 'Jenis Layanan 1',
                      initialServiceType: selectedServiceTypes['Jenis Layanan 1']!,
                      serviceTypes: const ['Laundry Kiloan'],
                      clothingItems: serviceSections['Jenis Layanan 1']!,
                      onQuantityChanged: (name, quantity) => 
                          updateClothingQuantity('Jenis Layanan 1', name, quantity),
                      onServiceTypeChanged: (type) => 
                          updateServiceType('Jenis Layanan 1', type),
                      showItemPrices: false,
                      showSubtotal: false, 
                      isPriced: false, 
                    ),
                    
                    // Service section 2 (Item-based with individual prices)
                    ServiceSection(
                      title: 'Jenis Layanan 2',
                      initialServiceType: selectedServiceTypes['Jenis Layanan 2']!,
                      serviceTypes: const ['Laundry Satuan'],
                      clothingItems: serviceSections['Jenis Layanan 2']!,
                      onQuantityChanged: (name, quantity) => 
                          updateClothingQuantity('Jenis Layanan 2', name, quantity),
                      onServiceTypeChanged: (type) => 
                          updateServiceType('Jenis Layanan 2', type),
                      showItemPrices: true,
                      showSubtotal: true, // Show subtotal for Layanan 2
                      isPriced: true, // This section has pricing
                    ),
                    
                    // Additional services
                    ...additionalServices.map((service) => 
                      AdditionalServiceCheckbox(
                        data: service,
                        onChanged: toggleAdditionalService,
                      )
                    ),
                    
                    // Additional services subtotal
                    if (additionalServicesSubtotal > 0)
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
                              'Rp ${additionalServicesSubtotal.toString()}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const Divider(thickness: 1),
                    const SizedBox(height: 16),
                    
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${total.toString()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006A4E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notes field
                    const Text(
                      'Catatan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            // Order button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle order button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006A4E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Buat Pesanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
