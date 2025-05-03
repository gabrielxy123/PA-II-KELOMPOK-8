import 'dart:convert';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/models/laundry.dart';
import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/toko_card.dart'; // You might want to rename this to laundry_card.dart later
import 'package:http/http.dart' as http;

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();

  List<Laundry> laundryList = []; // Changed from tokoList to laundryList
  List<Laundry> filteredLaundryList = []; // Changed from filteredTokoList
  bool isLoading = false;
  String errorMessage = '';
  bool _isCurrentlyVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchDataLaundry(); // Changed from fetchDataToko
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isCurrentlyVisible) {
      fetchDataLaundry(); // Changed from fetchDataToko
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      bool isActive = route.isCurrent;
      if (isActive && !_isCurrentlyVisible) {
        _isCurrentlyVisible = true;
        fetchDataLaundry(); // Changed from fetchDataToko
      } else if (!isActive && _isCurrentlyVisible) {
        _isCurrentlyVisible = false;
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredLaundryList = laundryList.where((laundry) {
        // Changed parameter name from Laundry to laundry
        return laundry.nama.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> fetchDataLaundry() async {
  if (isLoading) return;

  setState(() {
    isLoading = true;
    errorMessage = '';
  });

  try {
    final response = await http.get(
      Uri.parse('${Apiconstant.BASE_URL}/index-toko-user'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['data'] != null) {
        List<dynamic> laundryJsonList = data['data'];
        final parsedList = laundryJsonList.map((json) {
          try {
            return Laundry.fromJson(json);
          } catch (e) {
            print('Error parsing laundry item: $e');
            // Return default laundry item jika parsing gagal
            return Laundry(
              id: 0,
              nama: 'Error',
              noTelp: '',
              email: '',
              deskripsi: '',
              jalan: '',
              kecamatan: '',
              kabupaten: '',
              provinsi: '',
              waktuBuka: DateTime.now(),
              waktuTutup: DateTime.now(),
              buktiBayar: '',
              Status: '',
              logo: '',
            );
          }
        }).toList();

        setState(() {
          laundryList = parsedList;
          filteredLaundryList = parsedList;
        });
      } else {
        throw Exception('Data laundry tidak ditemukan.');
      }
    } else {
      throw Exception('Gagal memuat data laundry: ${response.body}');
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
            'Toko Laundry'), // You might want to change this to 'Laundry' if appropriate
      ),
      body: RefreshIndicator(
        onRefresh: fetchDataLaundry, // Changed from fetchDataToko
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search and Refresh Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari layanan...',
                        prefixIcon:
                            Icon(Icons.search, color: Colors.grey.shade600),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_upward, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Swipe ke atas untuk refresh halaman',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Content
              if (isLoading)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else if (errorMessage.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(errorMessage),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              fetchDataLaundry, // Changed from fetchDataToko
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filteredLaundryList
                  .isEmpty) // Changed from filteredTokoList
                const Expanded(
                    child: Center(
                        child: Text(
                            "Laundry tidak ditemukan."))) // Changed message
              else
                Expanded(
                  child: GridView.builder(
                    itemCount: filteredLaundryList
                        .length, // Changed from filteredTokoList
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3 / 4,
                    ),
                    itemBuilder: (context, index) {
                      return TokoCardWidget(
                          laundry: filteredLaundryList[
                              index]); // Assuming TokoCardWidget has been updated to accept Laundry
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
