import 'package:admin/widgets/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/admin_db.dart';
import './withdrawal_screen.dart';
// import 'package:project_flutter/screens/orders_screen.dart';
// import '../widgets/bottom_navbar.dart';
// import './withdrawal_screen.dart';
// import './profile_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String adminId = "+91 9789378657";
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late String adminId = widget.adminId;
  late CollectionReference<Map<String, dynamic>> _transactionStream;

  final int initialTransactionsCount = 5;
  bool _showAllTransactions = false;
  // final FirestoreService _firestoreService = FirestoreService();
  // final String partnerTranId = "+91 9789378657";

  @override
  void initState() {
    super.initState();
    // _paymentStream = _firestoreService.getProfileStream(partnerId);
    _transactionStream = FirebaseFirestore.instance.collection('transaction');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Earnings',
          style: GoogleFonts.pacifico(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              "Deligo",
              style: GoogleFonts.pacifico(fontSize: 32, color: Colors.white),
            ),
          ),
        ],
        backgroundColor: const Color(0xFFFF4B3A),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildEarningsSummary(),
            Expanded(child: _buildTransactionsList()),
            // const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildEarningsSummary() {
    return StreamBuilder<QuerySnapshot>(
      stream: _transactionStream.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        double totalEarnings = 0;
        double todaysEarnings = 0;
        double thisWeekEarnings = 0;
        int xCnt = 0;
        int yCnt = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          DateTime now = DateTime.now();
          DateTime startOfDay = DateTime(now.year, now.month, now.day);
          int daysSinceMonday = now.weekday - 1;
          DateTime startOfWeek = DateTime(
            now.year,
            now.month,
            now.day - daysSinceMonday,
          ); // Monday of the current week

          print('Now: $now');
          print('Start of day: $startOfDay');
          print('Start of week: $startOfWeek');

          totalEarnings = snapshot.data!.docs.fold(0.0, (total, doc) {
            final data = doc.data() as Map<String, dynamic>;
            double amount = (data['amount'] ?? 0).toDouble();

            if (data['date'] is Timestamp) {
              DateTime transactionDate = (data['date'] as Timestamp).toDate();

              // Check if the transaction is today
              if (transactionDate.isAfter(startOfDay) &&
                  transactionDate.isBefore(now)) {
                todaysEarnings += amount;
                xCnt++;
              }

              // Check if the transaction is this week
              if (transactionDate.isAfter(startOfWeek) &&
                  transactionDate.isBefore(now)) {
                thisWeekEarnings += amount;
                yCnt++;
              }
            }
            return total + amount;
          });
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF4B3A), Color(0xFFFF8329)],
            ),
          ),
          child: Column(
            children: [
              Text(
                '₹ ${totalEarnings.toStringAsFixed(2)}', // Total Earnings
                style: GoogleFonts.lato(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Earnings',
                style: GoogleFonts.lato(fontSize: 26, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildEarningsCard(
                    'Today',
                    '₹ ${todaysEarnings.toStringAsFixed(2)}',
                    '$xCnt deliveries',
                  ),
                  _buildEarningsCard(
                    'This Week',
                    '₹ ${thisWeekEarnings.toStringAsFixed(2)}',
                    '$yCnt deliveries',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEarningsCard(String title, String amount, String deliveries) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.lato(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            deliveries,
            style: GoogleFonts.lato(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    // Define these as class variables instead of local variables
    // to maintain state between rebuilds

    return StreamBuilder<QuerySnapshot>(
      stream: _transactionStream.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        List<QueryDocumentSnapshot> allTransactions = [];

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          allTransactions = snapshot.data!.docs.toList();

          // Sort transactions by date in descending order (most recent first)
          allTransactions.sort((a, b) {
            DateTime dateA = (a['date'] as Timestamp).toDate();
            DateTime dateB = (b['date'] as Timestamp).toDate();
            return dateB.compareTo(dateA);
          });
        }

        // Determine which transactions to display based on _showAllTransactions flag
        List<QueryDocumentSnapshot> transactionsToDisplay =
            _showAllTransactions
                ? allTransactions.toList()
                : allTransactions.take(initialTransactionsCount).toList();

        return Column(
          children: [
            // Transaction list
            Expanded(
              child: ListView.builder(
                itemCount: transactionsToDisplay.length,
                itemBuilder: (context, index) {
                  final doc = transactionsToDisplay[index];
                  final transaction = doc.data() as Map<String, dynamic>;

                  DateTime dateTime;
                  if (transaction['date'] is Timestamp) {
                    dateTime = (transaction['date'] as Timestamp).toDate();
                  } else {
                    dateTime =
                        DateTime.tryParse(transaction['date'].toString()) ??
                        DateTime.now();
                  }

                  String formattedDate = DateFormat(
                    'dd MMM yyyy',
                  ).format(dateTime);
                  String formattedTime = DateFormat('hh:mm a').format(dateTime);

                  return _buildTransactionCard(
                    date: formattedDate,
                    time: formattedTime,
                    orderNumber: transaction['orderNumber'].toString(),
                    amount: '₹ ${transaction['amount'].toString() ?? '0'}',
                    type: transaction['type'].toString() ?? 'Payment',
                  );
                },
              ),
            ),

            // "See More" button
            if (allTransactions.length > initialTransactionsCount)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllTransactions = !_showAllTransactions;
                    });
                  },
                  child: Text(
                    _showAllTransactions ? 'Show Less' : 'See More',
                    style: GoogleFonts.lato(
                      color: const Color(0xFFFF4B3A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard({
    required String date,
    required String time,
    required String orderNumber,
    required String amount,
    required String type,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 10, right: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4B3A).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              type == 'cash' ? Icons.money : Icons.payment,
              color: const Color(0xFFFF4B3A),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order $orderNumber',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date at $time',
                  style: GoogleFonts.lato(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFFFF4B3A),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      type == 'cash'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type,
                  style: GoogleFonts.lato(
                    color: type == 'cash' ? Colors.green : Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWithDrawSection() {
    return Builder(
      builder:
          (context) => Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WithdrawalScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4B3A),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Withdraw Payout',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }
}
