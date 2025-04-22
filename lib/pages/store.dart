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

  class _StorePageState extends State<StorePage> {
    final TextEditingController _searchController = TextEditingController();

    List<Toko> tokoList = [];
    List<Toko> filteredTokoList = [];
    bool isLoading = false;
    String errorMessage = '';

    @override
    void initState() {
      super.initState();
      fetchDataToko();
      _searchController.addListener(_onSearchChanged);
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
        setState(() {
          errorMessage = e.toString();
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Toko Laundry'),
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
              if (isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (errorMessage.isNotEmpty)
                Expanded(child: Center(child: Text(errorMessage)))
              else if (filteredTokoList.isEmpty)
                const Expanded(
                    child: Center(child: Text("Toko tidak ditemukan.")))
              else
                Expanded(
                  child: GridView.builder(
                    itemCount: filteredTokoList.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
      );
    }
  }
