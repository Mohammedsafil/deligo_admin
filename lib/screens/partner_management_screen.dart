import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerManagementScreen extends StatefulWidget {
  const PartnerManagementScreen({Key? key}) : super(key: key);

  @override
  State<PartnerManagementScreen> createState() =>
      _PartnerManagementScreenState();
}

class _PartnerManagementScreenState extends State<PartnerManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isAddingPartner = false;
  String? _editingPartnerId;
  bool _isLoading = false;

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
        title: const Text(
          'Manage Partners',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.withOpacity(0.1),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search partners...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Show filter options
                  },
                  tooltip: 'Filter partners',
                ),
              ],
            ),
          ),

          // Stats summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatCard('Total Partners', 'Loading...', Icons.people),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Active Now',
                  'Loading...',
                  Icons.delivery_dining,
                ),
              ],
            ),
          ),

          // Partner list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('delivery_partners').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  );
                }

                final partners = snapshot.data?.docs ?? [];

                if (partners.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_accounts,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No partners yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showPartnerForm(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add your first partner'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: partners.length,
                  itemBuilder: (context, index) {
                    final partner =
                        partners[index].data() as Map<String, dynamic>;
                    final partnerId = partners[index].id;

                    // Get delivery statistics
                    final stats =
                        partner['delivery_statistics'] ??
                        {
                          'deliveries': 0,
                          'rating': 5.0,
                          'on_time_percentage': 100,
                        };

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Partner avatar/icon
                                CircleAvatar(
                                  backgroundColor: Colors.red.shade100,
                                  radius: 25,
                                  child: Text(
                                    partner['name']
                                        .toString()
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Partner details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        partner['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            partner['mobile_no'],
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.two_wheeler,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${partner['vehicle']['bike_name']} (${partner['vehicle']['numberplate']})',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Action buttons
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      tooltip: 'Edit partner',
                                      onPressed:
                                          () =>
                                              _editPartner(partnerId, partner),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Delete partner',
                                      onPressed:
                                          () => _deletePartner(partnerId),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Performance metrics
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildMetric(
                                    'Deliveries',
                                    stats['deliveries'].toString(),
                                    Icons.delivery_dining,
                                  ),
                                  _buildDivider(),
                                  _buildMetric(
                                    'Rating',
                                    '${stats['rating']}★',
                                    Icons.star,
                                  ),
                                  _buildDivider(),
                                  _buildMetric(
                                    'On-time',
                                    '${stats['on_time_percentage']}%',
                                    Icons.timer,
                                  ),
                                ],
                              ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPartnerForm(),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Partner', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.red),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.grey[300]);
  }

  void _showPartnerForm({String? partnerId, Map<String, dynamic>? partner}) {
    if (partner != null) {
      _nameController.text = partner['name'];
      _mobileController.text = partner['mobile_no'].replaceAll("+91 ", "");
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form header
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isAddingPartner ? 'Add New Partner' : 'Edit Partner',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Personal Information Section
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _mobileController,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: const Icon(Icons.phone),
                        prefixText: '+91 ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter mobile number';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return 'Enter a valid 10-digit mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Vehicle Information Section
                    const Text(
                      'Vehicle Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bikeNameController,
                      decoration: InputDecoration(
                        labelText: 'Bike Model',
                        prefixIcon: const Icon(Icons.two_wheeler),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter bike model';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _numberPlateController,
                            decoration: InputDecoration(
                              labelText: 'Number Plate',
                              prefixIcon: const Icon(Icons.time_to_leave),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter number plate';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _licenseController,
                            decoration: InputDecoration(
                              labelText: 'License Number',
                              prefixIcon: const Icon(Icons.card_membership),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter license number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _savePartner,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  _isAddingPartner
                                      ? 'Add Partner'
                                      : 'Update Partner',
                                  style: const TextStyle(
                                    fontSize: 16,
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

  Future<void> _savePartner() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final partnerData = {
          'name': _nameController.text.trim(),
          'mobile_no': "+91 ${_mobileController.text.trim()}",
          'vehicle': {
            'bike_name': _bikeNameController.text.trim(),
            'numberplate': _numberPlateController.text.trim().toUpperCase(),
            'license': _licenseController.text.trim().toUpperCase(),
          },
          'delivery_statistics': {
            'deliveries': 0,
            'rating': 5.0,
            'on_time_percentage': 100,
          },
          'status': 'active',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };

        if (_isAddingPartner) {
          // Create partner login record
          await _firestore.collection('partnerlogin').add({
            'partnerId': partnerData['mobile_no'],
            'created_at': FieldValue.serverTimestamp(),
          });

          // Add new partner
          await _firestore.collection('delivery_partners').add(partnerData);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Partner added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (_editingPartnerId != null) {
          // Update existing partner
          partnerData['updated_at'] = FieldValue.serverTimestamp();
          await _firestore
              .collection('delivery_partners')
              .doc(_editingPartnerId)
              .update(partnerData);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Partner updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
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
        builder:
            (context) => AlertDialog(
              title: const Text('Delete Partner'),
              content: const Text(
                'Are you sure you want to delete this partner? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      // Get partner mobile number to delete login record
                      final partnerDoc =
                          await _firestore
                              .collection('delivery_partners')
                              .doc(partnerId)
                              .get();
                      final partnerData =
                          partnerDoc.data() as Map<String, dynamic>?;
                      final mobileNo = partnerData?['mobile_no'];

                      // Delete partner document
                      await _firestore
                          .collection('delivery_partners')
                          .doc(partnerId)
                          .delete();

                      // Delete login credentials - find by mobile number
                      if (mobileNo != null) {
                        final loginQuery =
                            await _firestore
                                .collection('partnerlogin')
                                .where('partnerId', isEqualTo: mobileNo)
                                .get();

                        for (final doc in loginQuery.docs) {
                          await doc.reference.delete();
                        }
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Partner deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error deleting partner: ${e.toString()}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
