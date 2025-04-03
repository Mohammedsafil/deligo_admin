import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onNotificationPressed;
  final IconData notificationIcon;

  const AppHeader({
    Key? key,
    required this.title,
    required this.onNotificationPressed,
    required this.notificationIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: GoogleFonts.pacifico(fontSize: 30, color: Colors.red),
      ),
      actions: [
        IconButton(
          icon: Icon(notificationIcon),
          onPressed: onNotificationPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}