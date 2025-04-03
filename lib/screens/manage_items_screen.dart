import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageItemsScreen extends StatefulWidget {
  const ManageItemsScreen({Key? key}) : super(key: key);

  @override
  _ManageItemsScreenState createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
  final TextEditingController stockController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  // 🔹 Function to Update Stock
  void _updateStock(String docId, int? currentStock) async {
    int newStock = int.tryParse(stockController.text) ?? currentStock ?? 0;
    await FirebaseFirestore.instance.collection('food_items').doc(docId).update({
      'stock': newStock,
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Stock Updated Successfully!"),
    ));

    stockController.clear();
  }

  // 🔹 Function to Edit Item Details
  void _editItem(DocumentSnapshot item) {
    TextEditingController nameController = TextEditingController(text: item['name']);
    TextEditingController surnameController = TextEditingController(text: item['surname'] ?? "");
    TextEditingController priceController = TextEditingController(text: item['price'].toString());
    TextEditingController descriptionController = TextEditingController(text: item['description']);
    TextEditingController stockEditController = TextEditingController(text: item['stock']?.toString() ?? "0");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, "Food Name"),
              const SizedBox(height: 10),
              _buildTextField(surnameController, "Surname"),
              const SizedBox(height: 10),
              _buildTextField(priceController, "Price", isNumeric: true),
              const SizedBox(height: 10),
              _buildTextField(descriptionController, "Description"),
              const SizedBox(height: 10),
              _buildTextField(stockEditController, "Stock", isNumeric: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('food_items').doc(item.id).update({
                  'name': nameController.text,
                  'surname': surnameController.text,
                  'price': double.parse(priceController.text),
                  'description': descriptionController.text,
                  'stock': int.tryParse(stockEditController.text) ?? 0,
                });

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Item Updated Successfully!"),
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

  // 🔹 Function to Build Input Fields
  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Items"),
        backgroundColor: const Color(0xFFFF4B3A),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Food Items",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // 🔹 Food Items List
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('food_items').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var items = snapshot.data!.docs;

                // 🔍 Apply search filter
                var filteredItems = items.where((item) {
                  return item['name'].toString().toLowerCase().contains(searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    var item = filteredItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: Text(item['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Surname: ${item['surname'] ?? 'N/A'}", style: TextStyle(color: Colors.grey[700])),
                            Text("Category: ${item['category']}", style: TextStyle(color: Colors.grey[700])),
                            Text("Type: ${item['type']}", style: TextStyle(color: Colors.grey[700])),
                            Text("Price: ₹${item['price']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Text("Stock: ${item['stock'] ?? 0}", style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editItem(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.green),
                              onPressed: () {
                                stockController.text = item['stock']?.toString() ?? "0";
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Edit Stock"),
                                      content: _buildTextField(stockController, "Enter New Stock", isNumeric: true),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _updateStock(item.id, int.tryParse(stockController.text));
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Update"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
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