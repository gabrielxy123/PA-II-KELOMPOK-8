import 'package:flutter/material.dart';
import 'package:carilaundry2/pages/order_detail.dart';
import 'package:carilaundry2/pages/order_rating.dart';
import 'package:carilaundry2/widgets/bottom_navigation.dart';
import 'package:carilaundry2/widgets/search_bar.dart';
import 'package:carilaundry2/widgets/top_bar.dart';
import 'package:carilaundry2/widgets/laundry_card.dart';
import 'package:carilaundry2/widgets/banner_widget.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Riwayat Transaksi'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          indicator: BoxDecoration(
            color: Colors.green,
          ),
          indicatorSize: TabBarIndicatorSize
              .tab, // This makes the indicator span the entire tab
          tabs: const [
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Text('Transaksi Terkini'),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Text('Selesai'),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Transaksi Terkini
          ListView(
            children: [
              _buildOrderItem(
                laundryName: 'AGIAN LAUNDRY',
                phoneNumber: '(123-456-789)',
                status: 'Sedang Diproses',
                orderNumber: 'ORD-001',
                isCompleted: false,
              ),
            ],
          ),
          
          // Tab Selesai
          ListView(
            children: [
              _buildOrderItem(
                laundryName: 'AGIAN LAUNDRY',
                phoneNumber: '(123-456-789)',
                status: 'Selesai',
                orderNumber: 'ORD-002',
                isCompleted: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem({
    required String laundryName,
    required String phoneNumber,
    required String status,
    required String orderNumber,
    required bool isCompleted,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          height: 100, // Fixed height for consistency
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Image.asset('assets/images/agian.png', width: 50, height: 50),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        laundryName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(phoneNumber),
                      Text(
                        status,
                        style: TextStyle(
                          color: isCompleted ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                isCompleted
                    ? SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderReviewPage(
                                  laundryName: laundryName,
                                  orderId: orderNumber,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text(
                            'Beri Penilaian',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailPage(
                                customerName: 'Budi Soetomo',
                                orderNumber: orderNumber,
                                orderDate: '25 Februari 2025',
                                status: status,
                                products: [
                                  {
                                    'name': 'Kaos',
                                    'quantity': 3,
                                    'unitPrice': 7000,
                                    'totalPrice': 21000
                                  },
                                  {
                                    'name': 'Kemeja',
                                    'quantity': 3,
                                    'unitPrice': 9000,
                                    'totalPrice': 27000
                                  },
                                  {
                                    'name': 'Celana',
                                    'quantity': 3,
                                    'unitPrice': 10000,
                                    'totalPrice': 30000
                                  },
                                ],
                                extraCost: 5000,
                                totalCost: 220000,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Lihat Selengkapnya',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
