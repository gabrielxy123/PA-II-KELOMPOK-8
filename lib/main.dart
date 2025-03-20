import 'package:carilaundry2/pages/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carilaundry2/pages/dashboard.dart';
import 'package:carilaundry2/pages/home.dart';
import 'package:carilaundry2/pages/login.dart';
import 'package:carilaundry2/pages/profil.dart';
import 'package:carilaundry2/pages/single_order.dart';
import 'package:carilaundry2/pages/main_container.dart';
import 'package:carilaundry2/utils/constants.dart';

// Global key for app-wide SnackBars
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// import 'package:carilaundry2/widgets/top_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
    case "/":
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return Home();
        },
      );
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
    case "/toko":
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
    case "/profile":
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return ProfilePage();
        },
      );
    default:
      return MaterialPageRoute(
        builder: (BuildContext context) {
          return Home();
        },
      );
  }
}
