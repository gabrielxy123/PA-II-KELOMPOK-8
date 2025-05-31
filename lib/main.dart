import 'package:carilaundry2/pages/pengusaha/customer_request_page.dart';
import 'package:carilaundry2/pages/pengusaha/toko_detail.dart';
import 'package:carilaundry2/pages/pengusaha/toko_profile.dart';
import 'package:carilaundry2/pages/register.dart';
import 'package:carilaundry2/pages/store_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carilaundry2/pages/login.dart';
import 'package:carilaundry2/pages/single_order.dart';
import 'package:carilaundry2/pages/main_container.dart';
import 'package:carilaundry2/utils/constants.dart';
import 'package:carilaundry2/pages/order_menu.dart';
import 'package:carilaundry2/pages/halaman_toko.dart';
import 'package:carilaundry2/pages/register_toko.dart';
import 'package:carilaundry2/pages/notifikasi.dart';
import 'package:carilaundry2/pages/store_profile.dart';
import 'package:carilaundry2/pages/upload_pembayaran.dart';
import 'package:carilaundry2/pages/admin/request_list.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:carilaundry2/AuthProvider/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const singleOrder = '/single-order';
  static const order = '/order';
  static const store = '/store';
  static const userProfile = '/user-profil';
  static const notification = '/notification';
  static const orderHistory = '/order-history';
  static const orderMenu = '/order-menu';
  static const halamanToko = '/halaman-toko';
  static const registerToko = '/register-toko';
  static const tokoProfile = '/toko-profile';
  static const tokoDetail = '/toko-detail';
  static const uploadPembayaran = '/upload-pembayaran';
  static const tesApprove = '/tes-approve';
  static const tokoSaya = '/toko-saya';
  static const profileTokoSaya = '/profile-toko-saya';
  static const transaksiToko = '/transaksi/request';
}

// Global key for app-wide SnackBars
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Buat instance global untuk plugin local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Inisialisasi local notifications
Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Tampilkan local notification
void _showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'default_channel', // ID Channel
    'Default Notifications', // Nama Channel
    channelDescription: 'Channel untuk notifikasi default',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    message.hashCode, // ID unik notifikasi
    message.notification?.title ?? 'Notifikasi Baru', // Judul
    message.notification?.body ?? 'Anda menerima notifikasi baru', // Isi
    notificationDetails,
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      final String title = message.notification?.title ?? "Notifikasi Baru";
      final String body =
          message.notification?.body ?? "Anda menerima notifikasi baru";

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null && Get.isDialogOpen != true) {
          Get.defaultDialog(
            title: title,
            content: Text(body),
            titlePadding: EdgeInsets.all(10),
            contentPadding: EdgeInsets.all(10),
            confirmTextColor: Colors.white,
            textConfirm: "Oke",
            onConfirm: () => Get.back(),
          );
        }
      });
    }
  });

  final authProvider = AuthProvider();
  await authProvider.checkLoginStatus();

  runApp(
    ChangeNotifierProvider(
      create: (_) => authProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Cari Laundry",
        theme: ThemeData(
          scaffoldBackgroundColor: Constants.scaffoldBackgroundColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.poppinsTextTheme(),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.fixed,
          ),
        ),
        initialRoute: AppRoutes.dashboard,
        getPages: [
          GetPage(name: AppRoutes.login, page: () => Login()),
          GetPage(name: AppRoutes.register, page: () => Register()),
          GetPage(
            name: AppRoutes.dashboard,
            page: () => MainContainer(initialIndex: 0),
          ),
          GetPage(name: AppRoutes.singleOrder, page: () => SingleOrder()),
          GetPage(
            name: AppRoutes.order,
            page: () => MainContainer(initialIndex: 1),
          ),
          GetPage(
            name: AppRoutes.store,
            page: () => MainContainer(initialIndex: 2),
          ),
          GetPage(
            name: AppRoutes.userProfile,
            page: () => MainContainer(initialIndex: 3),
          ),
          GetPage(
            name: AppRoutes.notification,
            page: () => NotificationScreen(),
          ),
          GetPage(
            name: AppRoutes.orderHistory,
            page: () => MainContainer(initialIndex: 1),
          ),
          GetPage(name: AppRoutes.orderMenu, page: () => OrderDetailScreen()),
          GetPage(name: AppRoutes.halamanToko, page: () => TokoPage()),
          GetPage(name: AppRoutes.registerToko, page: () => FormTokoPage()),
          GetPage(
              name: AppRoutes.tokoProfile, page: () => TokoProfileUserPage()),
          GetPage(name: AppRoutes.tokoDetail, page: () => TokoUserDetailPage()),
          GetPage(
            name: AppRoutes.uploadPembayaran,
            page: () => UploadPembayaran(),
          ),
          GetPage(name: AppRoutes.tesApprove, page: () => RequestListPage()),
          GetPage(name: AppRoutes.tokoSaya, page: () => TokoDetailPage()),
          GetPage(name: AppRoutes.transaksiToko, page: () => CustomerRequestPage()),
          GetPage(
            name: AppRoutes.profileTokoSaya,
            page: () => TokoProfilePage(),
          ),
        ],
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
