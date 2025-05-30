import 'package:flutter/material.dart';
import 'package:carilaundry2/pages/order_detail.dart';
import 'package:carilaundry2/pages/order_rating.dart';
import 'package:carilaundry2/widgets/bottom_navigation.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1;

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
        title: const Text('Riwayat Transaksi'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          indicator: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(5),
          ),
          tabs: const [
            Tab(text: 'Transaksi Terkini'),
            Tab(text: 'Selesai'),
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
      bottomNavigationBar: BottomNavigationBarWidget(
          selectedIndex: _selectedIndex, onItemTapped: (index) {
            setState(() {
              _selectedIndex = index;
            });
          }
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Image.asset('assets/images/agian.png', width: 50, height: 50),
        title: Text(
          laundryName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Total Pesanan: 2',
              style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        isCompleted
        ? ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderReviewPage(
                    laundryName: laundryName,
                    kodeTransaksi: orderNumber,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Beri Penilaian'),
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
    );
  }
}
