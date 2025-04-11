import 'package:carilaundry2/pages/order_menu.dart';
import 'package:carilaundry2/pages/register.dart';
import 'package:carilaundry2/pages/store_detail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carilaundry2/pages/dashboard.dart';
import 'package:carilaundry2/pages/login.dart';
// import 'package:carilaundry2/pages/profil.dart';
import 'package:carilaundry2/pages/single_order.dart';
import 'package:carilaundry2/pages/main_container.dart';
import 'package:carilaundry2/utils/constants.dart';
import 'package:carilaundry2/pages/order_history.dart';
import 'package:carilaundry2/pages/notifikasi.dart';
// import 'package:carilaundry2/pages/order_menu.dart';
// import 'package:carilaundry2/pages/store.dart';
import 'package:carilaundry2/pages/store_profile.dart';
import 'package:carilaundry2/pages/register_toko.dart';
import 'package:carilaundry2/service/notification_service.dart';


// Global key for app-wide SnackBars
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.instance.initialize();  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      builder: (context, child) => MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: "Flutter Laundry UI",
        theme: ThemeData(
          scaffoldBackgroundColor: Constants.scaffoldBackgroundColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.poppinsTextTheme(),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.fixed,
          ),
        ),
        initialRoute: "/dashboard",
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}

Route<dynamic> _onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case "/login":
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return Login();
        },
      );
    case "/register":
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return Register();
        },
      );
    case "/dashboard":
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return MainContainer(initialIndex: 0);
        },
        settings: settings,
      );
    case "/single-order":
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return SingleOrder();
        },
      );
    case "/order":
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return MainContainer(initialIndex: 1);
        },
      );
    case "/store":
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return MainContainer(initialIndex: 2);
        },
      );

    case "/user-profil":
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return MainContainer(initialIndex: 3);
        },
      );
    case "/notification":
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return NotificationScreen();
        },
      );
    // case "/store":
    //   return MaterialPageRoute(
    //     builder: (BuildContext context) {
    //       return StorePage();
    //     },
    //   );

    case "/order-history":
      return MaterialPageRoute(builder: (context) => OrderHistoryPage());
    case "/order-menu":
      return MaterialPageRoute(builder: (context) => OrderDetailScreen());

    case "/toko-profile":
      return MaterialPageRoute(builder: (context) => StoreProfilePage());

    case "/registrasi-toko":
      return MaterialPageRoute(builder: (context) => FormTokoPage());
  
    case "/toko-detail":
      return MaterialPageRoute(builder: (context) => StoreDetailPage());

    default:
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return Dashboard();
        },
      );
  }
}
