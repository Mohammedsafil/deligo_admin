import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerManagementScreen extends StatefulWidget {
  const PartnerManagementScreen({Key? key}) : super(key: key);

  @override
  State<PartnerManagementScreen> createState() => _PartnerManagementScreenState();
}

class _PartnerManagementScreenState extends State<PartnerManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isAddingPartner = false;
  String? _editingPartnerId;

  // Form controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _bikeNameController = TextEditingController();
  final _numberPlateController = TextEditingController();
  final _licenseController = TextEditingController();

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Partners'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('delivery_partners').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final partners = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: partners.length,
            itemBuilder: (context, index) {
              final partner = partners[index].data() as Map<String, dynamic>;
              final partnerId = partners[index].id;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(partner['name']),
                  subtitle: Text(partner['mobile_no']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editPartner(partnerId, partner),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deletePartner(partnerId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPartnerForm(),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPartnerForm({String? partnerId, Map<String, dynamic>? partner}) {
    if (partner != null) {
      _nameController.text = partner['name'];
      _mobileController.text = partner['mobile_no'];
      _bikeNameController.text = partner['vehicle']['bike_name'];
      _numberPlateController.text = partner['vehicle']['numberplate'];
      _licenseController.text = partner['vehicle']['license'];
      _isAddingPartner = false;
      _editingPartnerId = partnerId;
    } else {
      _nameController.clear();
      _mobileController.clear();
      _bikeNameController.clear();
      _numberPlateController.clear();
      _licenseController.clear();
      _isAddingPartner = true;
      _editingPartnerId = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isAddingPartner ? 'Add New Partner' : 'Edit Partner',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bikeNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bike Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter bike name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _numberPlateController,
                  decoration: const InputDecoration(
                    labelText: 'Number Plate',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number plate';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _licenseController,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter license number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _savePartner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(_isAddingPartner ? 'Add Partner' : 'Update Partner'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _savePartner() async {
    if (_formKey.currentState!.validate()) {
      try {
        final partnerData = {
          'name': _nameController.text,
          'mobile_no': "+91 " + _mobileController.text,
          'vehicle': {
            'bike_name': _bikeNameController.text,
            'numberplate': _numberPlateController.text,
            'license': _licenseController.text,
          },
          'delivery_statistics': {
            'deliveries': 0,
            'rating': 5.0,
            'on_time_percentage': 100,
          },
        };

        if (_isAddingPartner) {
          await _firestore.collection('partnerlogin').add({'partnerId': partnerData['mobile_no']});
          await _firestore.collection('delivery_partners').add(partnerData);
        } else if (_editingPartnerId != null) {
          await _firestore.collection('delivery_partners').doc(_editingPartnerId).update(partnerData);
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _editPartner(String partnerId, Map<String, dynamic> partner) {
    _showPartnerForm(partnerId: partnerId, partner: partner);
  }

  Future<void> _deletePartner(String partnerId) async {
    try {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Partner'),
          content: const Text('Are you sure you want to delete this partner?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _firestore.collection('delivery_partners').doc(partnerId).delete();
                await _firestore.collection('partnerlogin').doc(partnerId).delete();
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _bikeNameController.dispose();
    _numberPlateController.dispose();
    _licenseController.dispose();
    super.dispose();
  }
} 