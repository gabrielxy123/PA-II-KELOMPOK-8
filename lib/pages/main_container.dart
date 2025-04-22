import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/bottom_navigation.dart';
import 'package:carilaundry2/pages/dashboard.dart';
import 'package:carilaundry2/pages/profil.dart';
import 'package:carilaundry2/pages/order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carilaundry2/pages/store.dart';
import 'package:carilaundry2/pages/Halaman_Toko.dart';
import 'dart:io';
import 'package:flutter/services.dart';

// Global ScaffoldMessengerKey for snackbars
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MainContainer extends StatefulWidget {
  final int initialIndex;

  const MainContainer({
    super.key,
    this.initialIndex = 0,
  });

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
      OrderHistoryPage(),
      StorePage(), // Ganti Container dengan StorePage
      // TokoPage(), // Placeholder for Toko page
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Keluar Aplikasi"),
            content: Text("Apakah kamu yakin ingin keluar dari aplikasi?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Tidak"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Ya"),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          // Gunakan salah satu dari ini:

          // Kalau kamu pakai Android (lebih aman)
          SystemNavigator.pop();

          // ATAU (tidak disarankan di iOS)
          // exit(0);

          return true; // biar WillPopScope tahu kita lanjut
        }

        return false;
      },
      child: Scaffold(
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
      ),
    );
  }
}
