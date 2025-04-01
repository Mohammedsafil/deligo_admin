import 'package:admin/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
// import '../screens/reports_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/settings_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({Key? key, required this.selectedIndex}) : super(key: key);

  void _navigateToScreen(BuildContext context, int index) {
    if (index == selectedIndex) return; // Prevent reloading the same page

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const HomeScreen();
        break;
      case 1:
        nextScreen = const PaymentScreen();
        break;
      case 2:
        nextScreen = const MenuScreen();
        break;
      case 3:
        nextScreen = const SettingsScreen();
        break;
      default:
        nextScreen = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: const Color(0xFFFF4B3A),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed, // ✅ Fix icon shifting issue
      onTap: (index) => _navigateToScreen(context, index),
      items: [
        BottomNavigationBarItem(
          icon: SizedBox(
            height: 30, // ✅ Fix height to prevent shifting
            child: Icon(Icons.home, size: 28),
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            height: 30,
            child: Icon(Icons.receipt, size: 28),
          ),
          label: "Reports",
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            height: 30,
            child: Icon(Icons.menu, size: 28),
          ),
          label: "Menu",
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            height: 30,
            child: Icon(Icons.settings, size: 28),
          ),
          label: "Settings",
        ),
      ],
    );
  }
}
