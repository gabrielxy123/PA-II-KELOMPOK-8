import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/bottom_navigation.dart';
import 'package:carilaundry2/widgets/search_bar.dart';
import 'package:carilaundry2/widgets/top_bar.dart';
import 'package:carilaundry2/widgets/laundry_card.dart';
import 'package:carilaundry2/widgets/banner_widget.dart';

void main() {
  runApp(const Dashboard());
}

class Dashboard extends StatefulWidget {
  final String? userName;
  const Dashboard({Key? key, this.userName}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  int _currentBannerIndex = 0;
  final PageController _pageController = PageController();
  String? userName;

  @override
  void initState() {
    super.initState();
    //ambil data username
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if(args!=null && args is String) {
        userName = args;
      }
    });
    
    // Auto-scroll banner
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _autoScrollBanner();
      }
    });
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
                  TopBarWidget(),

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
                  childAspectRatio: 0.75,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
