import 'package:flutter/material.dart';

class OrderDetailPage extends StatelessWidget {
  final String customerName;
  final String orderNumber;
  final String orderDate;
  final String status;
  final List<Map<String, dynamic>> products;
  final int extraCost;
  final int totalCost;

  const OrderDetailPage({
    super.key,
    required this.customerName,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.products,
    required this.extraCost,
    required this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan', style: TextStyle(fontSize: 14)),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.green[100]!.withOpacity(0.1), // Bright green with 10% opacity
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Card(
            elevation: 3,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildDetailRow('Nama Toko', customerName, bold: true),
                  const SizedBox(height: 8),
                  _buildDetailRow('No. Pesanan', orderNumber),
                  const SizedBox(height: 8),
                  _buildDetailRow('Tanggal Pemesanan', orderDate),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status', style: TextStyle(fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'Selesai'
                              ? Colors.green[100]
                              : Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color: status == 'Selesai'
                                ? Colors.green[800]
                                : Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Table Header
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 2.0, color: Colors.black),
                        bottom: BorderSide(width: 2.0, color: Colors.black),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text('INFO PRODUK',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              flex: 1,
                              child: Text('JUMLAH',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center)),
                          Expanded(
                              flex: 2,
                              child: Text('HARGA',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right)),
                          Expanded(
                              flex: 2,
                              child: Text('TOTAL',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                  ),

                  // Product Rows
                  ...products
                      .map((product) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text(product['name'],
                                        style: const TextStyle(fontSize: 12))),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                        product['quantity'].toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 12))),
                                Expanded(
                                    flex: 2,
                                    child: Text('Rp${product['unitPrice']}',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 12))),
                                Expanded(
                                    flex: 2,
                                    child: Text('Rp${product['totalPrice']}',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 12))),
                              ],
                            ),
                          ))
                      .toList(),

                  const SizedBox(height: 16),

                  // Total Section
                  _buildTotalRow(
                      'Total Harga Laundry',
                      products.fold<int>(
                          0, (sum, item) => sum + (item['totalPrice'] as int))),
                  if (extraCost > 0)
                    _buildTotalRow('Extra Pelembut', extraCost),
                  const Divider(height: 16),
                  _buildTotalRow('Total Harga Keseluruhan', totalCost,
                      bold: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildTotalRow(String label, int amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text('Rp$amount',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}