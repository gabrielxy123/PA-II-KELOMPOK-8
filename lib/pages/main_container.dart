import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/bottom_navigation.dart';
import 'package:carilaundry2/pages/dashboard.dart';
import 'package:carilaundry2/pages/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global ScaffoldMessengerKey for snackbars
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MainContainer extends StatefulWidget {
  final int initialIndex;

  const MainContainer({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  late int _selectedIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _initPages();
  }

  void _initPages() {
    _pages = [
      Dashboard(),
      Container(
          child:
              Center(child: Text('Order Page'))), // Placeholder for Order page
      Container(
          child: Center(child: Text('Toko Page'))), // Placeholder for Toko page
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
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
