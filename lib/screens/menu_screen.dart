import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_header.dart';
import 'add_item_screen.dart';
import 'manage_items_screen.dart';
import 'manage_offers_screen.dart'; // ✅ Import ManageOffersScreen

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(
        title: "DeliGo",
        onNotificationPressed: () {
          // TODO: Handle notification click
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔹 Low Stock Alert Section (Dynamic)
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('food_items')
                  .where('stock', isLessThan: 10)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final lowStockItems = snapshot.data!.docs;

                if (lowStockItems.isEmpty) {
                  return const SizedBox(); // If no low stock items, show nothing
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Low Stock Alert!",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 5),

                      // 🔹 List of low stock items
                      ...lowStockItems.map((item) {
                        final itemName = item['name'];
                        final stock = item['stock'];
                        final itemId = item.id;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("• $itemName ($stock left)", style: const TextStyle(fontSize: 14)),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text("Restock", style: TextStyle(fontSize: 13)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 2,
                                ),
                                onPressed: () {
                                  _showRestockDialog(context, itemId, itemName, stock);
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // 🔹 Buttons moved here
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGradientButton(Icons.tune, "Manage Items", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageItemsScreen()),
                  );
                }),
                _buildGradientButton(Icons.add_circle_outline, "Add New Item", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddItemScreen()),
                  );
                }),
                _buildGradientButton(Icons.local_offer, "Manage Offers", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageOffersScreen()),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 2),
    );
  }

  void _showRestockDialog(BuildContext context, String itemId, String itemName, int currentStock) {
    final TextEditingController stockController =
    TextEditingController(text: currentStock.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Restock $itemName"),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "New stock quantity",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(stockController.text.trim());
              if (newStock == null || newStock < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid stock value.")),
                );
                return;
              }

              await FirebaseFirestore.instance
                  .collection('food_items')
                  .doc(itemId)
                  .update({'stock': newStock});

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$itemName stock updated to $newStock.")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // 🔹 Custom Gradient Button
  Widget _buildGradientButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4B3A), Color(0xFFFF8329)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white),
              const SizedBox(height: 5),
              Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
