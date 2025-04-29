import 'dart:convert';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:carilaundry2/models/toko.dart';
import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/toko_card.dart';
import 'package:http/http.dart' as http;

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();

  List<Toko> tokoList = [];
  List<Toko> filteredTokoList = [];
  bool isLoading = false;
  String errorMessage = '';

  // Add this to track if the page is currently visible
  bool _isCurrentlyVisible = false;

  @override
  void initState() {
    super.initState();
    // Register this object as an observer
    WidgetsBinding.instance.addObserver(this);
    fetchDataToko();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Unregister the observer
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // This method is called when the app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isCurrentlyVisible) {
      // App came back to foreground and this page is visible
      fetchDataToko();
    }
  }

  // Add this method to handle page visibility
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if the route is active
    final route = ModalRoute.of(context);
    if (route != null) {
      bool isActive = route.isCurrent;
      if (isActive && !_isCurrentlyVisible) {
        // Page became visible
        _isCurrentlyVisible = true;
        fetchDataToko();
      } else if (!isActive && _isCurrentlyVisible) {
        // Page is no longer visible
        _isCurrentlyVisible = false;
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredTokoList = tokoList.where((toko) {
        return toko.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> fetchDataToko() async {
    // Don't fetch if we're already loading
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

      // Check if the widget is still mounted before updating state
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null) {
          List<dynamic> tokoJsonList = data['data'];
          final parsedList =
              tokoJsonList.map((json) => Toko.fromJson(json)).toList();

          setState(() {
            tokoList = parsedList;
            filteredTokoList = parsedList;
          });
        } else {
          throw Exception('Data toko tidak ditemukan.');
        }
      } else {
        throw Exception('Gagal memuat data toko: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
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
        title: const Text('Toko Laundry'),
      ),
      body: RefreshIndicator(
        onRefresh: fetchDataToko,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search and Refresh Row
              Row(
                children: [
                  // Search TextField
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

              // Swipe to refresh instruction
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
                        // fontStyle: FontStyle.italic,
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
                          onPressed: fetchDataToko,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filteredTokoList.isEmpty)
                const Expanded(
                    child: Center(child: Text("Toko tidak ditemukan.")))
              else
                Expanded(
                  child: GridView.builder(
                    itemCount: filteredTokoList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3 / 4,
                    ),
                    itemBuilder: (context, index) {
                      return TokoCardWidget(toko: filteredTokoList[index]);
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
