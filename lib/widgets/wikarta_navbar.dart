import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WikartaNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const WikartaNavbar({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.lightBlue.withOpacity(0.91),
      selectedItemColor: AppColors.charcoal,
      unselectedItemColor: AppColors.coolGray,
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Pelanggan"),
        BottomNavigationBarItem(icon: Icon(Icons.wifi), label: "Paket"),
        BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Invoice"),
        BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: "Tiket"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
      ],
    );
  }
}