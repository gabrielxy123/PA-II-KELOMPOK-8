import 'package:carilaundry2/main.dart';
import 'package:carilaundry2/pages/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carilaundry2/pages/order_detail_nota.dart';
import '../models/notifikasi.dart';
import 'package:get/get.dart';
import '../service/notification.dart';
import 'dart:convert';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final notifications = await _notificationService.getNotifications();
      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      if (!mounted) return;

      setState(() {
        _notifications = _notifications.map((notification) {
          if (notification.id == notificationId) {
            return NotificationModel(
              id: notification.id,
              title: notification.title,
              body: notification.body,
              data: notification.data,
              isRead: true,
              createdAt: notification.createdAt,
            );
          }
          return notification;
        }).toList();
      });
    } catch (e) {
      debugPrint('Error marking as read: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal menandai notifikasi sebagai telah dibaca')),
      );
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      if (!mounted) return;

      setState(() {
        _notifications
            .removeWhere((notification) => notification.id == notificationId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notifikasi berhasil dihapus')),
      );
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus notifikasi')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      if (!mounted) return;

      setState(() {
        _notifications = _notifications.map((notification) {
          return NotificationModel(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            data: notification.data,
            isRead: true,
            createdAt: notification.createdAt,
          );
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Semua notifikasi ditandai sebagai telah dibaca')),
      );
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Gagal menandai semua notifikasi sebagai telah dibaca')),
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Hari ini, ${DateFormat('HH:mm').format(date)}';
      } else if (difference.inDays == 1) {
        return 'Kemarin, ${DateFormat('HH:mm').format(date)}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      } else {
        return DateFormat('dd MMM yyyy, HH:mm').format(date);
      }
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return dateString;
    }
  }

  void _handleNotificationTap(NotificationModel notification) async {
    // Tandai sebagai dibaca jika belum
    if (!notification.isRead) {
      await _markAsRead(notification.id);
    }

    // Pastikan widget masih mounted sebelum melanjutkan
    if (!mounted) return;

    try {
      debugPrint('Notification Received: ${notification.toString()}');

      Map<String, dynamic>? notificationData;

      // Handle different data types
      if (notification.data is String) {
        try {
          notificationData =
              jsonDecode(notification.data as String) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('Error parsing notification data: $e');
          notificationData = null;
        }
      } else if (notification.data is Map) {
        notificationData = notification.data as Map<String, dynamic>;
      }

      debugPrint('Parsed Notification Data: $notificationData');

      // Try to extract transaction code
      String? kodeTransaksi;
      String? eventType;

      if (notificationData != null) {
        kodeTransaksi = notificationData['kode_transaksi']?.toString() ??
            notificationData['transaction_code']?.toString() ??
            notificationData['code']?.toString();

        eventType = notificationData['event_type']?.toString() ??
            notificationData['type']?.toString();

        // If not found in data, try to extract from body
        if (kodeTransaksi == null) {
          final regex = RegExp(r'\b[A-Z0-9]{8,}\b');
          final match = regex.firstMatch(notification.body);
          if (match != null) {
            kodeTransaksi = match.group(0);
          }
        }
      }

      debugPrint('Extracted Kode Transaksi: $kodeTransaksi');
      debugPrint('Extracted Event Type: $eventType');
      if (!mounted) return;
      if (kodeTransaksi != null && kodeTransaksi.isNotEmpty) {
        if (eventType == null ||
            eventType.toLowerCase().contains('order') ||
            eventType.toLowerCase().contains('transaksi')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(
                kodeTransaksi: kodeTransaksi!, // Gunakan bang operator
              ),
            ),
          );
          return;
        }
      }

      // Default behavior - show notification content
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(notification.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.body),
                if (notificationData != null) ...[
                  SizedBox(height: 16),
                  Text(
                    'Data Notifikasi:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(notificationData.toString()),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat membuka notifikasi'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< Updated upstream
=======
        title: Text('Notifikasi'),
>>>>>>> Stashed changes
        backgroundColor: const Color(0xFF006A55),
        title: Text('Notifikasi', style: TextStyle(color: Colors.white)),
        actions: [
          if (_notifications.any((notification) => !notification.isRead))
            IconButton(
              icon: Icon(Icons.done_all),
              onPressed: _markAllAsRead,
<<<<<<< Updated upstream
              tooltip: 'Mark all as read',
              color: Colors.white,
=======
              tooltip: 'Tandai semua sebagai dibaca',
>>>>>>> Stashed changes
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNotifications,
<<<<<<< Updated upstream
            tooltip: 'Refresh',
            color: Colors.white,
=======
            tooltip: 'Muat ulang',
>>>>>>> Stashed changes
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
<<<<<<< Updated upstream
                      Text('Gagal untuk menampilkan notifikasi'),
=======
                      Text('Gagal memuat notifikasi'),
>>>>>>> Stashed changes
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        child: Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006A55),
                        ),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
<<<<<<< Updated upstream
                            'Belum Ada Notifikasi',
=======
                            'Belum ada notifikasi',
>>>>>>> Stashed changes
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return Dismissible(
                            key: Key(notification.id.toString()),
                            background: Container(
                              color: Colors.green,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(
                                Icons.done,
                                color: Colors.white,
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
<<<<<<< Updated upstream
                                      title: Text("Confirm"),
                                      content: Text(
                                          "Yakin untuk menghapus notifikasi ini?"),
=======
                                      title: Text("Konfirmasi"),
                                      content: Text(
                                          "Apakah Anda yakin ingin menghapus notifikasi ini?"),
>>>>>>> Stashed changes
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text("Batal"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text("Hapus"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                              return true;
                            },
                            onDismissed: (direction) {
                              if (direction == DismissDirection.endToStart) {
                                _deleteNotification(notification.id);
                              } else {
                                _markAsRead(notification.id);
                              }
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              elevation: notification.isRead ? 1 : 3,
                              color:
                                  notification.isRead ? null : Colors.grey[50],
<<<<<<< Updated upstream
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF006A55)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
=======
                              child: InkWell(
                                onTap: () =>
                                    _handleNotificationTap(notification),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
>>>>>>> Stashed changes
                                  ),
                                  leading: Stack(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF006A55)
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
<<<<<<< Updated upstream
                                      )
                                    : null,
                                onTap: () {
                                  if (!notification.isRead) {
                                    _markAsRead(notification.id);
                                  }
                                  // Handle notification tap - maybe navigate to related content
                                  if (notification.data != null) {
                                    // Handle navigation based on notification data
                                    final data = notification.data!;
                                    if (data.containsKey('event_type')) {
                                      String eventType = data['event_type'];
                                      switch (eventType) {
                                        case 'order_processed':
                                          Get.toNamed(AppRoutes.orderHistory);
                                          break;
                                        // Add other event types as needed
                                        case 'order_rejected':
                                          Get.toNamed(AppRoutes.orderHistory);
                                          break;
                                        case 'new_order':
                                          Get.toNamed(AppRoutes.transaksiToko);
                                          break;
                                        case 'store_approved':
                                          Get.toNamed(AppRoutes.tokoSaya);
                                          break;
                                        case 'order_done':
                                          Get.toNamed(AppRoutes.orderHistory);
                                      }
                                    }
                                  }
                                },
=======
                                        child: Icon(
                                          Icons.notifications,
                                          color: const Color(0xFF006A55),
                                          size: 20,
                                        ),
                                      ),
                                      if (!notification.isRead)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  title: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontWeight: notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(notification.body),
                                      SizedBox(height: 4),
                                      Text(
                                        _formatDate(notification.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // trailing dihapus agar tidak dobel indikator
                                ),
>>>>>>> Stashed changes
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
