import 'package:flutter/material.dart';
import 'package:carilaundry2/utils/constants.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavigationBarWidget({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: widget.selectedIndex,
      height: 60.0,
      items: [
        _buildNavItem(Icons.home_outlined, Icons.home),
        _buildNavItem(Icons.shopping_cart_outlined, Icons.shopping_cart),
        _buildNavItem(Icons.store_outlined, Icons.store),
        _buildNavItem(Icons.person_outline, Icons.person),
      ],
      color: Colors.white,
      buttonBackgroundColor: Constants.primaryColor.withOpacity(0.1),
      backgroundColor: Color(0xFFF5F7FA),
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      onTap: (index) {
        widget.onItemTapped(index);
      },
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon) {
    return Icon(
      widget.selectedIndex == _getIndex(icon) ? activeIcon : icon,
      color: widget.selectedIndex == _getIndex(icon)
          ? Constants.primaryColor
          : Colors.grey.shade600,
      size: 28,
    );
  }

  int _getIndex(IconData icon) {
    switch (icon) {
      case Icons.home_outlined:
        return 0;
      case Icons.shopping_cart_outlined:
        return 1;
      case Icons.store_outlined:
        return 2;
      case Icons.person_outline:
        return 3;
      default:
        return 0;
    }
  }
}
