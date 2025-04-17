import 'package:flutter/material.dart';

class FilterTabs extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildFilterTab('Menunggu', context),
        const SizedBox(width: 8),
        _buildFilterTab('Diterima', context),
        const SizedBox(width: 8),
        _buildFilterTab('Ditolak', context),
      ],
    );
  }

  Widget _buildFilterTab(String filter, BuildContext context) {
    final isSelected = selectedFilter == filter;
    
    return Expanded(
      child: InkWell(
        onTap: () => onFilterChanged(filter),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF006A4E) : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            filter,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
