import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../widgets/order_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_header.dart'; // Import the AppHeader

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<String> _tabs = ["All", "Pending", "Done"];

  List<Order> orders = [
    Order(
      name: "Tanya Leon",
      orderId: "745632",
      items: 6,
      price: 250.00,
      status: "Pending",
    ),
    Order(
      name: "Brandon Oneal",
      orderId: "745632",
      items: 1,
      price: 15.00,
      status: "Pending",
    ),
    Order(
      name: "Michaela Schneider",
      orderId: "856252",
      items: 5,
      price: 120.00,
      status: "Pending",
    ),
    Order(
      name: "Cornelius Hopkins",
      orderId: "525896",
      items: 3,
      price: 82.00,
      status: "Pending",
    ),
    Order(
      name: "Talon Roberson",
      orderId: "638852",
      items: 2,
      price: 26.00,
      status: "Pending",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppHeader(
        title: "DeliGo",
        onNotificationPressed: () {
          // Handle notification press
        },
      ),

      body: Column(
        children: [
          // Title: "Orders" aligned to the left
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Orders",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Tabs
          Container(
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
                        style: TextStyle(
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

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: "Search",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Order List
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return OrderCard(order: orders[index]);
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }
}
