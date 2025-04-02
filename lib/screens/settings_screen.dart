import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_nav_bar.dart';
import 'partner_management_screen.dart';
import 'payment_screen.dart';
import 'signin_screen.dart'; // Import SignInScreen

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom App Header with "DeliGo" title and Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // "DeliGo" Title (with the same style as AppHeader)
                Text(
                  "DeliGo",
                  style: GoogleFonts.pacifico(
                    fontSize: 30,
                    color: Colors.red,
                  ),
                ),
                // Logout Button (moved to top right)
                _buildLogoutButton(context),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage(
                              'assets/profile.png',
                            ), // Replace with actual asset
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsTile(context, "Edit Profile", () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Staff Management Section
                  _buildSettingsSection("Staff Management", [
                    _buildSettingsTile(context, "Manage Staffs", () {}),
                    _buildSettingsTile(context, "Manage Partners", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PartnerManagementScreen(),
                        ),
                      );
                    }),
                  ]),
                  const SizedBox(height: 20),

                  // Payments & Payouts Section
                  _buildSettingsSection("Payments & Payouts", [
                    _buildSettingsTile(context, "View Earnings & Payouts", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentScreen(),
                        ),
                      );
                    }),
                    _buildSettingsTile(context, "Manage Bank Accounts", () {}),
                  ]),
                  const SizedBox(height: 20),

                  // Security & Access Section
                  _buildSettingsSection("Security & Access", [
                    _buildSettingsTile(
                        context, "Two-Factor Authentication", () {}),
                    _buildSettingsTile(context, "Manage Admin Roles", () {}),
                  ]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 3,
      ), // Active Settings Tab
    );
  }

  // Builds a Settings Section with a rounded border
  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  // Builds individual setting items
  Widget _buildSettingsTile(
      BuildContext context,
      String title,
      VoidCallback onTap,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 1,
              blurRadius: 2,
            ),
          ],
        ),
        child: ListTile(
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }

  // Logout button moved to top-right corner, navigates to SignInScreen
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: const Icon(Icons.logout, color: Colors.white),
        onPressed: () {
          // Navigate to SignInScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        },
      ),
    );
  }
}
