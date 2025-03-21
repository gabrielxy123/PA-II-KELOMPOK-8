import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/search_bar.dart';
import 'package:carilaundry2/widgets/top_bar.dart';
import 'package:carilaundry2/widgets/laundry_card.dart';
import 'package:carilaundry2/widgets/banner_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    home: Dashboard(),
  ));
}

class Dashboard extends StatefulWidget {
  final String? userName;
  const Dashboard({Key? key, this.userName}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentBannerIndex = 0;
  final PageController _pageController = PageController();
  bool isLoggedIn = false;
  String? userName;
  String? userProfileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Auto-scroll banner
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _autoScrollBanner();
      }
    });
  }

  // Method untuk mengambil data pengguna dari SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      userName = prefs.getString('userName');
    });

    // Ambil data username dari arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is String) {
        setState(() {
          userName = args;
        });
      }
    });

    // Fetch user profile data if logged in
    if (isLoggedIn) {
      await _fetchUserProfile();
    }
  }

  // Method to fetch user profile data including profile image
  Future<void> _fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      if (token.isEmpty) {
        print('Token is empty, user not logged in');
        return;
      }

      final response = await http.get(
        Uri.parse('http://172.30.40.71:8000/api/user-profil'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Profile fetch response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            userProfileImage = data['data']['profile_image'] ?? '';
            // Save profile image URL to shared preferences for quick access
            prefs.setString('userProfileImage', userProfileImage ?? '');
          });
          print('Fetched profile image URL: $userProfileImage');
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  void _autoScrollBanner() {
    if (!mounted) return;

    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients) {
        if (_currentBannerIndex < 3) {
          _currentBannerIndex++;
        } else {
          _currentBannerIndex = 0;
        }

        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
      _autoScrollBanner();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Top Bar
                  TopBarWidget(
                    isLoggedIn: isLoggedIn,
                    userName: userName,
                    userProfileImage: userProfileImage,
                  ),

                  // Search Bar
                  const SearchBarWidget(),

                  // Banner Carousel
                  BannerCarouselWidget(
                    pageController: _pageController,
                    currentBannerIndex: _currentBannerIndex,
                    onPageChanged: (index) {
                      setState(() {
                        _currentBannerIndex = index;
                      });
                    },
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final services = [
                      LaundryServiceCardWidget(
                        title: 'Laundry Sepatu',
                        logoAsset: 'assets/images/agian.png',
                        description: 'okokok.',
                        price: 'Rp.15.000.00',
                      ),
                      LaundryServiceCardWidget(
                        title: 'Laundry Cover',
                        logoAsset: 'assets/images/fanya.png',
                        description: 'okokok.',
                        price: 'Rp.25.000.00',
                      ),
                      LaundryServiceCardWidget(
                        title: 'Laundry Cover Bed',
                        logoAsset: 'assets/images/agian.png',
                        description: 'okokok.',
                        price: 'Rp.20.000.00',
                      ),
                      LaundryServiceCardWidget(
                        title: 'Laundry Jas',
                        logoAsset: 'assets/images/agian.png',
                        description: 'okook',
                        price: 'Rp.20.000.00',
                      ),
                    ];
                    return services[index % services.length];
                  },
                  childCount: 6,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.66,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
