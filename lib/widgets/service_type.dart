import 'package:flutter/material.dart';


class ServiceTypeDropdown extends StatefulWidget {
  const ServiceTypeDropdown({super.key});

  @override
  State<ServiceTypeDropdown> createState() => _ServiceTypeDropdownState();
}

class _ServiceTypeDropdownState extends State<ServiceTypeDropdown> {
  String selectedService = 'Cuci + Setrika';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Layanan',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedService,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: <String>[
                'Cuci + Setrika',
                'Cuci Saja',
                'Setrika Saja',
                'Dry Cleaning',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedService = newValue!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

