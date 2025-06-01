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
    if (!notification.isRead) {
      await _markAsRead(notification.id);
    }

    if (!mounted) return;

    try {
      debugPrint('Notification Received: ${notification.toString()}');

      Map<String, dynamic>? notificationData;

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

      String? kodeTransaksi;
      String? eventType;

      if (notificationData != null) {
        kodeTransaksi = notificationData['kode_transaksi']?.toString() ??
            notificationData['transaction_code']?.toString() ??
            notificationData['code']?.toString();

        eventType = notificationData['event_type']?.toString() ??
            notificationData['type']?.toString();

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

      // Handle specific event types that should go to order detail page
      if (eventType != null &&
          kodeTransaksi != null &&
          kodeTransaksi.isNotEmpty) {
        switch (eventType) {
          case 'order_done':
          case 'order_processed':
          case 'order_rejected':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailPage(
                  kodeTransaksi: kodeTransaksi!,
                ),
              ),
            );
            return;
          case 'new_order':
            Get.toNamed(AppRoutes.transaksiToko);
            return;
          case 'store_approved':
            Get.toNamed(AppRoutes.tokoSaya);
            return;
        }
      }

      // Fallback: if we have transaction code but no specific event type
      if (kodeTransaksi != null && kodeTransaksi.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(
              kodeTransaksi: kodeTransaksi!,
            ),
          ),
        );
        return;
      }

      // Show dialog if no transaction code found
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
        backgroundColor: const Color(0xFF006A55),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifikasi', style: TextStyle(color: Colors.white)),
        actions: [
          if (_notifications.any((notification) => !notification.isRead))
            IconButton(
              icon: Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
              color: Colors.white,
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Refresh',
            color: Colors.white,
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
                      Text('Silahkan Login Terlebih Dahulu'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text('Login',
                            style: TextStyle(color: Colors.white)),
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
                            'Belum Ada Notifikasi',
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
                                      title: Text("Confirm"),
                                      content: Text(
                                          "Yakin untuk menghapus notifikasi ini?"),
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
                              elevation: 4, // Increased shadow
                              shadowColor: Colors.black26, // Shadow color
                              color: Colors.white, // White background
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: notification.isRead
                                      ? Colors.grey.shade300
                                      : const Color(0xFF006A55)
                                          .withOpacity(0.3), // Outline color
                                  width: 1,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  // Additional shadow effect
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
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
                                      border: Border.all(
                                        color: const Color(0xFF006A55)
                                            .withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.notifications,
                                      color: const Color(0xFF006A55),
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontWeight: notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                        notification.body,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
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
                                  trailing: !notification.isRead
                                      ? Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.redAccent
                                                    .withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        )
                                      : null,
                                  onTap: () =>
                                      _handleNotificationTap(notification),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
