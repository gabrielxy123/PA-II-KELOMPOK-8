import 'dart:convert';
import 'package:carilaundry2/core/apiConstant.dart';
import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/search_bar.dart';
import 'package:carilaundry2/widgets/top_bar.dart';
import 'package:carilaundry2/widgets/banner_widget.dart';
import 'package:carilaundry2/widgets/laundry_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:carilaundry2/models/laundry.dart';

class Dashboard extends StatefulWidget {
  static const routeName = '/dashboard';
  final String? userName;
  const Dashboard({super.key, this.userName});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // final int _selectedIndex = 0;
  int _currentBannerIndex = 0;
  final PageController _pageController = PageController();

  List<dynamic> tokoList = [];
  List<dynamic> filteredTokoList = [];
  bool isLoading = false;
  String errorMessage = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchDataToko();
    Future.delayed(const Duration(seconds: 3), _autoScrollBanner);
  }

  void _autoScrollBanner() {
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _pageController.hasClients) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % 4;
        });
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        _autoScrollBanner();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchDataToko() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/index-dashboard-user'),
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            tokoList = data['data'];
            _filterTokoList(); // Apply any existing search filter
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

  void _filterTokoList() {
    if (searchQuery.isEmpty) {
      filteredTokoList = List.from(tokoList);
    } else {
      filteredTokoList = tokoList.where((toko) {
        final nama = toko['nama']?.toString().toLowerCase() ?? '';
        final jalan = toko['jalan']?.toString().toLowerCase() ?? '';
        final query = searchQuery.toLowerCase();

        return nama.contains(query) || jalan.contains(query);
      }).toList();
    }
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
      _filterTokoList();
    });
  }

  Future<void> _handleRefresh() async {
    return fetchDataToko();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const TopBarWidget(),
                    SearchBarWidget(onSearch: _handleSearch),
                    BannerCarouselWidget(
                      pageController: _pageController,
                      currentBannerIndex: _currentBannerIndex,
                      onPageChanged: (index) {
                        setState(() {
                          _currentBannerIndex = index;
                        });
                      },
                    ),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : filteredTokoList.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Text(
                                searchQuery.isEmpty
                                    ? 'Tidak ada data toko.'
                                    : 'Tidak ada hasil untuk "$searchQuery"',
                              ),
                            ),
                          )
                        : SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final toko = filteredTokoList[index];
                                return LaundryServiceCardWidget(
                                  title: toko['nama'] ?? 'Nama tidak tersedia',
                                  logoAsset: toko['logo'] ??
                                      'assets/images/default_logo.png',
                                  description:
                                      toko['jalan'] ?? 'Alamat tidak tersedia',
                                  price: 'Pesan Sekarang',
                                  laundryId: toko['id'],
                                );
                              },
                              childCount: filteredTokoList.length,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
