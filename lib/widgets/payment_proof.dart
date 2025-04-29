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

  String _getImageUrl() {
    final buktiBayar = toko['bukti_bayar'] ?? toko['buktiBayar'];

    if (buktiBayar == null || buktiBayar.isEmpty) {
      return ''; // Return empty string if no proof available
    }

    // If already a full URL, return as is
    if (buktiBayar.startsWith('http')) {
      return buktiBayar;
    }

    // Handle cases where path might already have 'storage/'
    if (buktiBayar.startsWith('storage/')) {
      return '${Apiconstant.BASE_URL}/${buktiBayar}';
    }

    // Default case - construct proper URL
    return '${Apiconstant.BASE_URL}/storage/bukti_pembayaran/$buktiBayar';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();
    final hasProof = imageUrl.isNotEmpty;

    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16),
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Toko: ${toko['nama'] ?? 'Tidak ada nama'}'),
            Text('Tanggal Upload: ${formatDate(toko['updated_at'])}'),
            SizedBox(height: 16),
            Expanded(
              child: hasProof
                  ? InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: EdgeInsets.all(20),
                      minScale: 0.5,
                      maxScale: 4,
                      child: Image.network(
                        imageUrl,
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
                              if (imageUrl.contains('storage'))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Pastikan file ada di server',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tidak ada bukti pembayaran'),
                        ],
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
