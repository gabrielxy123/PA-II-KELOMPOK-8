import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/search_bar.dart'; // Memanggil search bar yang sudah ada

class LaundryService {
  final String title;
  final String logoAsset;
  final String description;
  final String price;

  LaundryService({
    required this.title,
    required this.logoAsset,
    required this.description,
    required this.price,
  });
}

class Store {
  static List<LaundryService> laundryServices = [
    LaundryService(
      title: 'Laundry Sepatu',
      logoAsset: 'assets/images/agian.png',
      description: 'Cuci sepatu dengan teknik khusus agar bersih dan wangi.',
      price: 'Rp.15.000',
    ),
    LaundryService(
      title: 'Laundry Cover',
      logoAsset: 'assets/images/fanya.png',
      description: 'Cuci dan setrika cover dengan bahan berkualitas.',
      price: 'Rp.25.000',
    ),
  ];
}

class StorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Toko Laundry',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
        backgroundColor: const Color(0xFF006A55),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchBarWidget(), // Memanggil search bar pada body
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: Store.laundryServices.length,
                itemBuilder: (context, index) {
                  final service = Store.laundryServices[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(service.logoAsset, height: 50),
                          const SizedBox(height: 8),
                          Text(service.title,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(service.description,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () {
                              // Add your button action here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006A55),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              service.price,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
