import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/search_bar.dart';
import 'package:carilaundry2/pages/store_detail.dart';

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

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final TextEditingController _searchController = TextEditingController();
  List<LaundryService> _filteredServices = [];

  List<LaundryService> _allServices = [
    LaundryService(
      title: 'Agian Laundry',
      logoAsset: 'assets/images/agian.png',
      description: 'Cuci sepatu dengan teknik khusus agar bersih dan wangi.',
      price: 'Rp.15.000',
    ),
    LaundryService(
      title: 'Laundry Fanya',
      logoAsset: 'assets/images/fanya.png',
      description: 'Cuci dan setrika cover dengan bahan berkualitas.',
      price: 'Rp.25.000',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredServices = _allServices;
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterServices);
    _searchController.dispose();
    super.dispose();
  }

  void _filterServices() {
    setState(() {
      _filteredServices = _allServices
          .where((service) => service.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Toko Laundry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari layanan...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: _filteredServices.length,
                itemBuilder: (context, index) {
                  final service = _filteredServices[index];
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StoreDetailPage()),
                              );
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
