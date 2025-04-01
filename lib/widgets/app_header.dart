import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onNotificationPressed;

  const AppHeader({
    Key? key,
    required this.title,
    required this.onNotificationPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: GoogleFonts.pacifico(
          fontSize: 30,
          color: Colors.red,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, size: 28, color: Colors.black87),
          onPressed: onNotificationPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
