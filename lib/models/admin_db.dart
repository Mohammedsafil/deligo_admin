import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createProfile(
    String partnerId,
    String name,
    String mobile,
    int deliveries,
    double rating,
    double onTimePercentage,
    String bikeName,
    String numberPlate,
    String license,
  ) async {
    await _db.collection('delivery_partners').doc(mobile).set({
      'name': name,
      'mobile_no': mobile,
      'delivery_statistics': {
        'deliveries': deliveries,
        'rating': rating,
        'on_time_percentage': onTimePercentage,
      },
      'vehicle': {
        'bike_name': bikeName,
        'number_plate': numberPlate,
        'license': license,
      },
    });
  }

  Future<void> updateProfile(
    String partnerId,
    Map<String, dynamic> updates,
  ) async {
    await _db.collection('delivery_partners').doc(partnerId).update(updates);
  }

  Future<void> deleteProfile(String partnerId) async {
    await _db.collection('delivery_partners').doc(partnerId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getProfileStream(
    String partnerId,
  ) {
    return _db
        .collection('delivery_partners')
        .where(partnerId, isEqualTo: partnerId)
        .snapshots();
  }

  Future<void> getTransactionIds() async {
    CollectionReference transactions = FirebaseFirestore.instance.collection(
      'transaction',
    );

    QuerySnapshot snapshot = await transactions.get();

    List<String> transactionIds = snapshot.docs.map((doc) => doc.id).toList();

    print(transactionIds); // Output: ['001', '002']
  }

  Future<void> saveLogin(String mobileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('adminMobile', mobileNumber);
  }

  Future<bool> authPartner(String id) async {
    try {
      QuerySnapshot partnerlog =
          await FirebaseFirestore.instance
              .collection('admins')
              .where('adminId', isEqualTo: id)
              .get();

      print("Documents found: ${partnerlog.docs.length}"); // Deb
      return partnerlog.docs.isNotEmpty;
    } catch (e) {
      print("Firestore query error: $e"); // More specific error log
      return false;
    }
  }

  Future<String> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('adminMobile') ?? '';
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminMobile');
  }

  Future<int> getActivePartnerCount() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('partnerlogin')
            .where('active', isEqualTo: true)
            .get();
    print("Documents found: ${snapshot.docs.length}");
    return snapshot.docs.length;
  }

  Future<int> getTotalPartnerCount() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('partnerlogin').get();
    print("Documents found: ${snapshot.docs.length}");
    return snapshot.docs.length;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAdminProfileStream(
    String adminId,
  ) {
    return _db.collection('admins').where('adminId', isEqualTo: adminId).get();
  }

  Future<void> updateAdminProfile(
    String adminId,
    Map<String, dynamic> updates,
  ) async {
    // First, find the document with this adminId field
    final QuerySnapshot snapshot =
        await _db
            .collection('admins')
            .where('adminId', isEqualTo: adminId)
            .get();

    if (snapshot.docs.isNotEmpty) {
      // Get the actual document ID
      final String docId = snapshot.docs.first.id;
      // Update using the document ID
      await _db.collection('admins').doc(docId).update(updates);
    } else {
      throw Exception('Admin document not found');
    }
  }
}
