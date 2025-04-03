import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;
  String? selectedType;
  Uint8List? _imageBytes;

  final List<String> categories = ['Veg', 'Non-Veg'];
  final List<String> types = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

  // 🔹 Pick an Image
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  // 🔹 Save Item to Firebase
  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection("food_items").add({
          'name': foodNameController.text,
          // 'surname': surnameController.text,
          'category': selectedCategory,
          'type': selectedType,
          'price': double.parse(priceController.text),
          'description': descriptionController.text,
          'stock': 0,
          'image': '', // Image is picked but NOT uploaded
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item Added Successfully!")),
        );

        Navigator.pop(context); // Go back to previous screen
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Item",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF4B3A), // DeliGo Theme Color
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Image Picker with Shadow Effect
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child:
                        _imageBytes == null
                            ? const Center(
                              child: Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey,
                              ),
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _imageBytes!,
                                fit: BoxFit.cover,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Input Fields with Shadows
                _buildTextField(
                  foodNameController,
                  "Food Name",
                  "Enter food name",
                ),
                const SizedBox(height: 15),
                // _buildTextField(surnameController, "Surname", "Enter surname"),
                // const SizedBox(height: 15),

                // 🔹 Category Dropdown
                _buildDropdown(
                  label: "Select Category",
                  value: selectedCategory,
                  items: categories,
                  onChanged:
                      (value) => setState(() => selectedCategory = value),
                ),
                const SizedBox(height: 15),

                // 🔹 Type Dropdown
                _buildDropdown(
                  label: "Select Type",
                  value: selectedType,
                  items: types,
                  onChanged: (value) => setState(() => selectedType = value),
                ),
                const SizedBox(height: 15),

                // 🔹 Price Input with Shadow
                _buildTextField(
                  priceController,
                  "Price",
                  "Enter price",
                  isNumeric: true,
                ),
                const SizedBox(height: 15),

                // 🔹 Description Input
                _buildTextField(
                  descriptionController,
                  "Description",
                  "Enter description",
                  isMultiLine: true,
                ),
                const SizedBox(height: 20),

                // 🔹 Submit Button with Gradient and Shadow
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.3),
                      backgroundColor: const Color(
                        0xFFFF4B3A,
                      ), // DeliGo Primary Color
                    ),
                    child: const Text(
                      "Add Item",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Custom Text Field Widget with Shadow
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String validationMsg, {
    bool isNumeric = false,
    bool isMultiLine = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType:
            isNumeric
                ? TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
        maxLines: isMultiLine ? 3 : 1,
        decoration: _inputDecoration(label),
        validator: (value) => value!.isEmpty ? validationMsg : null,
      ),
    );
  }

  // 🔹 Custom Dropdown Widget
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
        decoration: _inputDecoration(label),
        validator: (value) => value == null ? "Please select $label" : null,
      ),
    );
  }

  // 🔹 Custom Input Decoration with Shadow
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey[100],
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF4B3A), width: 2),
      ),
    );
  }
}
