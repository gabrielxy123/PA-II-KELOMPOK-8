import 'package:flutter/material.dart';
import 'package:carilaundry2/pages/store_profile.dart';

class StoreDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Toko Laundry - Laundry Agian',
          style: TextStyle(fontSize: 15),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 15),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF006A55),
              padding: EdgeInsets.all(35.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to StoreProfilePage on image tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StoreProfilePage()),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(20.0),
                        child: Image.asset(
                          'assets/images/agian.png',
                          height: 50,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laundry Agian',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: 18),
                          Text(
                            ' 4.8 (244)',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        '300+ Pesanan Selesai',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jenis-jenis layanan laundry',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  SizedBox(height: 25),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    children: [
                      _buildServiceItem('Kaos', 'assets/images/agian.png'),
                      _buildServiceItem('Kemeja', 'assets/images/agian.png'),
                      _buildServiceItem('Celana', 'assets/images/agian.png'),
                      _buildServiceItem('Jaket', 'assets/images/agian.png'),
                      _buildServiceItem('Sepatu', 'assets/images/agian.png'),
                      _buildServiceItem('Selimut', 'assets/images/agian.png'),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/order-menu");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006A55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Text(
                          'Pesan Sekarang',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Ulasan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _buildReview('Virgo18', 5, 'Pelayanan cepat dan rapi!'),
                  _buildReview('Raya', 5, 'Sangat memuaskan!'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String title, String imagePath) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFE4EEEC),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color:
                    const Color.fromARGB(255, 157, 155, 155).withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildReview(String name, int stars, String review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: List.generate(
              stars,
              (index) => Icon(Icons.star, color: Colors.orange, size: 16),
            ),
          ),
          Text(review),
        ],
      ),
    );
  }
}
