import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/packages_screen.dart';
import 'screens/invoices_screen.dart';
import 'screens/tickets_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const WikartaApp());
}

class WikartaApp extends StatelessWidget {
  const WikartaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Wikarta Mobile",
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/customers': (context) => const CustomersScreen(),
        '/packages': (context) => const PackagesScreen(),
        '/invoices': (context) => const InvoicesScreen(),
        '/tickets': (context) => const TicketsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}