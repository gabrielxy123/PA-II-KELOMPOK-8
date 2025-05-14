import 'package:carilaundry2/core/apiConstant.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Inisialisasi FCM
  Future<void> initializeFcm(String userId) async {
    try {
      // Mendapatkan token FCM
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print("FCM Token: $token");

        // Simpan token ke backend
        await saveTokenToBackend(userId, token);

        // Setup listener untuk token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) async {
          print("FCM Token refreshed: $newToken");
          await saveTokenToBackend(userId, newToken);
        });
      }
    } catch (e) {
      print("Error initializing FCM: $e");
    }
  }

  // Simpan token ke backend
  Future<void> saveTokenToBackend(String userId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${Apiconstant.BASE_URL}/save-token'),
        body: {
          'id_user': userId,
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        print('Token saved successfully');
      } else {
        print('Failed to save token: ${response.body}');
      }
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  // Kirim notifikasi lokal (opsional, untuk debugging)
  void showNotification(String title, String body) {
    // Implementasi notifikasi lokal menggunakan plugin seperti flutter_local_notifications
    print("Notification Received: $title - $body");
  }
}
