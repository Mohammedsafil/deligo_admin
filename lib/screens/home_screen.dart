import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart' as myOrder;
import '../widgets/order_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<String> _tabs = ["New", "Active", "Completed"];
  List<myOrder.Order> orders = [];

  @override
  void initState() {
    super.initState();
    fetchItemsFromFirestore();
  }

  Future<void> fetchItemsFromFirestore() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await firestore.collection('Orders').get();

      List<myOrder.Order> fetchedOrders =
          snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return myOrder.Order(
              id: data['orderId'],
              customerName: data['customerName'],
              delivery: data['deliveryType'],
              orderDate: (data['orderDate'] as Timestamp).toDate(),
              orderedItems: List<Map<String, dynamic>>.from(
                (data['orderedItems'] as List).map(
                  (item) => Map<String, dynamic>.from(item),
                ),
              ),
              subTotal: (data['subtotal'] as num).toDouble(),
              deliveryCost: (data['deliveryCost'] as num).toDouble(),
              totalCost: (data['totalCost'] as num).toDouble(),
              status: data['status'],
              paymentMethod: data['paymentMethod'],
              deliveryLocation:
                  data['deliveryLocation'] is GeoPoint
                      ? "${(data['deliveryLocation'] as GeoPoint).latitude}, ${(data['deliveryLocation'] as GeoPoint).longitude}"
                      : (data['deliveryLocation'] ?? 'Unknown location'),
              distance: (data['distance'] as num).toDouble(),
              mobile: data['mobile'],
              partnerId: data['partnerId'],
            );
          }).toList();
      print(fetchedOrders);
      setState(() {
        orders = fetchedOrders;
      });
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<myOrder.Order> acceptedOrders =
        orders
            .where(
              (order) =>
                  order.status != "delivered" && order.status != "pickup",
            )
            .toList();
    List<myOrder.Order> pendingOrders =
        orders.where((order) => order.status == "pickup").toList();
    List<myOrder.Order> deliveredOrders =
        orders.where((order) => order.status == "delivered").toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppHeader(
        title: "DeliGo",
        onNotificationPressed: () {
          setState(() {});
        },
        notificationIcon: Icons.notifications_off,
      ),
      body: RefreshIndicator(
        onRefresh: fetchItemsFromFirestore,
        backgroundColor: Colors.white,
        color: Colors.black,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Orders",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _tabs.length,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          _tabs[index],
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                _selectedIndex == index
                                    ? const Color(0xFFFF4B3A)
                                    : Colors.grey,
                          ),
                        ),
                        if (_selectedIndex == index)
                          Container(
                            width: 40,
                            height: 3,
                            color: const Color(0xFFFF4B3A),
                            margin: const EdgeInsets.only(top: 5),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: "Search",
                  hintStyle: GoogleFonts.inter(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            if (_selectedIndex == 0) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: pendingOrders.length,
                  itemBuilder: (context, index) {
                    return OrderCard(order: pendingOrders[index]);
                  },
                ),
              ),
            ] else if (_selectedIndex == 1) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: acceptedOrders.length,
                  itemBuilder: (context, index) {
                    return OrderCard(order: acceptedOrders[index]);
                  },
                ),
              ),
            ] else if (_selectedIndex == 2) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: deliveredOrders.length,
                  itemBuilder: (context, index) {
                    return OrderCard(order: deliveredOrders[index]);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }
}
