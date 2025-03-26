import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/bottom_navigation.dart';
import 'package:carilaundry2/widgets/search_bar.dart';
import 'package:carilaundry2/widgets/top_bar.dart';
import 'package:carilaundry2/widgets/laundry_card.dart';
import 'package:carilaundry2/widgets/banner_widget.dart';
import 'package:carilaundry2/pages/order_history.dart'; 

class OrderDetailPage extends StatelessWidget {
  final String customerName;
  final String orderNumber;
  final String orderDate;
  final String status;
  final List<Map<String, dynamic>> products;
  final int extraCost;
  final int totalCost;

  const OrderDetailPage({
    Key? key,
    required this.customerName,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.products,
    required this.extraCost,
    required this.totalCost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nama Pelanggan', customerName, bold: true),
            _buildDetailRow('No. Pesanan', orderNumber, bold: true),
            _buildDetailRow('Tanggal Pemesanan', orderDate, bold: true),
            _buildDetailRow('Status', status, bold: true, color: status == 'Selesai' ? Colors.green : Colors.orange),
            const Divider(),
            const SizedBox(height: 10),
            _buildTableHeader(),
            ...products.map((product) => _buildTableRow(
                  product['name'],
                  product['quantity'].toString(),
                  'Rp${product['unitPrice']}',
                  'Rp${product['totalPrice']}',
                )),
            const Divider(),
            _buildTotalRow('Total Harga Laundry', products.fold<int>(0, (sum, item) => sum + (item['totalPrice'] as int))),
            _buildTotalRow('Extra Pelembut', extraCost),
            _buildTotalRow('Total Harga Keseluruhan', totalCost, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Expanded(flex: 3, child: Text('INFO PRODUK', style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 1, child: Text('JUMLAH', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 2, child: Text('HARGA SATUAN', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(flex: 2, child: Text('TOTAL', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildTableRow(String name, String quantity, String unitPrice, String totalPrice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 3, child: Text(name)),
          Expanded(flex: 1, child: Text(quantity, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(unitPrice, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(totalPrice, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, int amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text('Rp$amount', style: TextStyle(fontSize: 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
