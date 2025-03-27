import 'package:flutter/material.dart';

class OrderReviewPage extends StatefulWidget {
  final String laundryName;
  final String orderId;

  const OrderReviewPage({
    Key? key,
    required this.laundryName,
    required this.orderId,
  }) : super(key: key);

  @override
  _OrderReviewPageState createState() => _OrderReviewPageState();
}

class _OrderReviewPageState extends State<OrderReviewPage> {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  void _submitReview() {
    // Simpan review ke backend atau database
    print("Laundry: ${widget.laundryName}");
    print("Order ID: ${widget.orderId}");
    print("Rating: $_rating");
    print("Review: ${_reviewController.text}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Penilaian Anda telah dikirim!')),
    );

    Navigator.pop(context); // Kembali ke halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Beri Penilaian untuk ${widget.laundryName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: 'Tulis ulasan...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Kirim Ulasan'),
            ),
          ],
        ),
      ),
    );
  }
}