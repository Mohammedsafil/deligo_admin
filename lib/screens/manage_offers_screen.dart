import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageOffersScreen extends StatefulWidget {
  const ManageOffersScreen({Key? key}) : super(key: key);

  @override
  _ManageOffersScreenState createState() => _ManageOffersScreenState();
}

class _ManageOffersScreenState extends State<ManageOffersScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  final TextEditingController contentController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  // 🔹 Function to Show Dialog for Admin to Enter Offer Details
  void _showAddOfferDialog(DocumentSnapshot foodItem) {
    contentController.text = ""; // Reset fields
    imageController.text = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Offer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: "Offer Content",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: imageController,
                decoration: InputDecoration(
                  labelText: "Image URL",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isEmpty || imageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please enter all details!"),
                  ));
                  return;
                }

                await FirebaseFirestore.instance.collection('banner').add({
                  'itemid': foodItem.id, // Store the selected food item ID
                  'content': contentController.text, // Manually entered content
                  'image': imageController.text, // Manually entered image URL
                });

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Offer Added Successfully!"),
                ));

                Navigator.pop(context);
              },
              child: const Text("Add Offer"),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Function to Delete an Offer
  void _deleteOffer(String offerId) async {
    await FirebaseFirestore.instance.collection('banner').doc(offerId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Offer Deleted Successfully!"),
    ));
  }

  // 🔹 Function to Edit an Offer
  void _editOffer(DocumentSnapshot offer) {
    contentController.text = offer['content'];
    imageController.text = offer['image'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Offer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: "Offer Content",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: imageController,
                decoration: InputDecoration(
                  labelText: "Image URL",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isEmpty || imageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please enter all details!"),
                  ));
                  return;
                }

                await FirebaseFirestore.instance.collection('banner').doc(offer.id).update({
                  'content': contentController.text,
                  'image': imageController.text,
                });

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Offer Updated Successfully!"),
                ));

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Offers"),
        backgroundColor: const Color(0xFFFF4B3A),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: Column(
        children: [
          // 🔹 Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search Food Items...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // 🔹 Display Search Results from 'food_items' Collection
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('food_items').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var foodItems = snapshot.data!.docs.where((doc) {
                  return doc['name'].toString().toLowerCase().contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: foodItems.length,
                  itemBuilder: (context, index) {
                    var foodItem = foodItems[index];
                    return ListTile(
                      title: Text(foodItem['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: ElevatedButton(
                        onPressed: () => _showAddOfferDialog(foodItem),
                        child: const Text("Add"),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(),

          // 🔹 Display Offers from 'banner' Collection
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('banner').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var offers = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    var offer = offers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: offer['image'] != null
                            ? Image.network(offer['image'], width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.local_offer),
                        title: Text(offer['content'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editOffer(offer),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteOffer(offer.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
