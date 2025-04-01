import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/signin_screen.dart'; // ✅ Updated Import

class OpeningScreen extends StatelessWidget {
  const OpeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF4B3A), Color(0xFFFF4B3A), Color(0xFFFF8329)],
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            Text(
              'DeliGo',
              style: GoogleFonts.pacifico(
                fontSize: 50,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  // ✅ Now navigates to SignInScreen instead of '/home'
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                },
                child: Text(
                  'Get Started',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Color(0xFFFF460A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
