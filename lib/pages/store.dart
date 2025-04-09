import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/search_bar.dart';
import 'package:carilaundry2/widgets/toko_card.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final TextEditingController _searchController = TextEditingController();
  // List<LaundryService> _filteredServices = [];

  // List<LaundryService> _allServices = [
  //   LaundryService(
  //     title: 'Agian Laundry',
  //     logoAsset: 'assets/images/agian.png',
  //     description: 'Cuci sepatu dengan teknik khusus agar bersih dan wangi.',
  //     price: 'Rp.15.000',
  //   ),
  //   LaundryService(
  //     title: 'Laundry Fanya',
  //     logoAsset: 'assets/images/fanya.png',
  //     description: 'Cuci dan setrika cover dengan bahan berkualitas.',
  //     price: 'Rp.25.000',
  //   ),
  // ];

  // @override
  // void initState() {
  //   super.initState();
  //   _filteredServices = _allServices;
  //   _searchController.addListener(_filterServices);
  // }

  // @override
  // void dispose() {
  //   _searchController.removeListener(_filterServices);
  //   _searchController.dispose();
  //   super.dispose();
  // }

  // void _filterServices() {
  //   setState(() {
  //     _filteredServices = _allServices
  //         .where((service) => LaundryServiceCardWidget.tit
  //             .toLowerCase()
  //             .contains(_searchController.text.toLowerCase()))
  //         .toList();
  //   });
  // }

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
            child: GridView.count(
              crossAxisCount: 2, // 2 cards per row
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.6, // Adjust card aspect ratio
              children: [
                TokoCardWidget(
                  title: 'Laundry Agian',
                  logoAsset: 'assets/images/agian.png',
                  description: 'Jl. PI DEL Laguboti',
                  price: 'Cek Detail',
                ),
                TokoCardWidget(
                  title: 'Laundry Fanya',
                  logoAsset: 'assets/images/fanya.png',
                  description: 'Jl. PI Del Laguboti',
                  price: 'Cek Detail',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}