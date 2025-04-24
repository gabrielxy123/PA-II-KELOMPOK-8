import 'package:flutter/material.dart';
import 'package:carilaundry2/core/apiConstant.dart';

class PaymentProofDialog extends StatelessWidget {
  final Map<String, dynamic> toko;
  final Function formatDate;
  final VoidCallback onBackToDetail;

  const PaymentProofDialog({
    Key? key,
    required this.toko,
    required this.formatDate,
    required this.onBackToDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bukti Pembayaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Toko: ${toko['nama'] ?? 'Tidak ada nama'}'),
            Text('Tanggal Upload: ${formatDate(toko['updated_at'])}'),
            SizedBox(height: 16),
            Flexible(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  '${Apiconstant.BASE_URL}${toko['buktiBayar']}',
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Gagal memuat gambar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onBackToDetail();
                  },
                  child: Text('Kembali ke Detail'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}