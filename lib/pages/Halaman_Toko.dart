import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:carilaundry2/pages/order_detail.dart';
import 'package:carilaundry2/pages/order_rating.dart';
import 'package:carilaundry2/pages/dashboard.dart';
import 'package:carilaundry2/widgets/bottom_navigation.dart';
import 'package:carilaundry2/widgets/search_bar.dart';
import 'package:carilaundry2/widgets/top_bar.dart';
import 'package:carilaundry2/widgets/laundry_card.dart';
import 'package:carilaundry2/widgets/banner_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TokoPage(),
    );
  }
}

class TokoPage extends StatefulWidget {
  const TokoPage({super.key});

  @override
  State<TokoPage> createState() => _TokoPageState();
}

class _TokoPageState extends State<TokoPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> allStores = [
    {"name": "Laundry Sepatu", "address": "Jl. Pi Del, Laguboti", "price": "Rp.15.000", "logo": "assets/agian.png"},
    {"name": "Laundry Kain", "address": "Jl. Pi Del, Laguboti", "price": "Rp.15.000", "logo": "assets/laundryfam.png"},
    {"name": "Laundry Sepatu", "address": "Jl. Pi Del, Laguboti", "price": "Rp.15.000", "logo": "assets/agian.png"},
    {"name": "Laundry Kain", "address": "Jl. Pi Del, Laguboti", "price": "Rp.15.000", "logo": "assets/laundryfam.png"},
  ];
  List<Map<String, String>> filteredStores = [];

  @override
  void initState() {
    super.initState();
    filteredStores = allStores;
  }

  void _filterStores(String query) {
    setState(() {
      filteredStores = allStores
          .where((store) => store["name"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: "Cari",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _filterStores,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Tambahkan aksi filter di sini
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: filteredStores.length,
          itemBuilder: (context, index) {
            final store = filteredStores[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.asset(store["logo"]!, fit: BoxFit.contain),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          store["name"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(store["address"]!, textAlign: TextAlign.center),
                        const SizedBox(height: 5),
                        Text(
                          "Harga mulai dari",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          store["price"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Order"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Toko"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }
}