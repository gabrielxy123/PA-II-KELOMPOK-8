import 'package:flutter/material.dart';

class LaundryServiceCardWidget extends StatefulWidget {
  final String title;
  final String logoAsset;
  final String description;
  final String price;

  const LaundryServiceCardWidget({
    Key? key,
    required this.title,
    required this.logoAsset,
    required this.description,
    required this.price,
  }) : super(key: key);

  @override
  State<LaundryServiceCardWidget> createState() => _LaundryServiceCardWidgetState();
}

class _LaundryServiceCardWidgetState extends State<LaundryServiceCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo
          Expanded(
            flex: 3,
            child: Center(
              child: Image.asset(
                widget.logoAsset,
                height: 80,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.local_laundry_service),
                  );
                },
              ),
            ),
          ),
          // Title and Description
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Price Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(156, 0, 105, 84),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                widget.price,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
