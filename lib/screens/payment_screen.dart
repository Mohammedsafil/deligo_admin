import 'package:admin/widgets/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/admin_db.dart';
import './withdrawal_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
  final int incrementAmount = 5;
  int _currentTransactionsCount = 5;
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
          ],
        ),
      ),

      // Add the floating action button here
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showReportOptions(context);
        },
        backgroundColor: const Color(0xFFFF4B3A),
        child: const Icon(Icons.receipt, color: Colors.white),
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

        // Determine which transactions to display based on _currentTransactionsCount
        List<QueryDocumentSnapshot> transactionsToDisplay =
            allTransactions.take(_currentTransactionsCount).toList();

        bool hasMoreTransactions =
            _currentTransactionsCount < allTransactions.length;
        bool showingAllTransactions =
            _currentTransactionsCount >= allTransactions.length;

        return Expanded(
          child: ListView.builder(
            itemCount:
                transactionsToDisplay.length +
                1, // +1 for the button at the end
            itemBuilder: (context, index) {
              // When we reach the end of the transactions list, show the appropriate button
              if (index == transactionsToDisplay.length) {
                // Show the appropriate button based on whether we're showing all transactions
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 20.0,
                  ),
                  child:
                      showingAllTransactions
                          ? _buildViewButton(
                            text: "View Less",
                            icon: Icons.keyboard_arrow_up,
                            onPressed: () {
                              setState(() {
                                _currentTransactionsCount =
                                    initialTransactionsCount;
                              });
                            },
                          )
                          : _buildViewButton(
                            text: "View More",
                            icon: Icons.keyboard_arrow_down,
                            onPressed: () {
                              setState(() {
                                // Show next batch of transactions
                                _currentTransactionsCount =
                                    _currentTransactionsCount + incrementAmount;
                                if (_currentTransactionsCount >
                                    allTransactions.length) {
                                  _currentTransactionsCount =
                                      allTransactions.length;
                                }
                              });
                            },
                          ),
                );
              }

              // Display transaction cards
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

              String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
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

  Widget _buildViewButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFF4B3A), Color(0xFFFF8329)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4B3A).withOpacity(0.25),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white),
              ],
            ),
          ),
        ),
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

  void _showReportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Transaction Report',
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF4B3A),
                  ),
                ),
                const SizedBox(height: 20),
                _buildReportOption(
                  context,
                  icon: Icons.picture_as_pdf,
                  title: 'Save as PDF',
                  description: 'Save report to your device',
                  onTap: () {
                    Navigator.pop(context);
                    _generateAndSavePdf(context);
                  },
                ),
                const Divider(height: 30),
                _buildReportOption(
                  context,
                  icon: Icons.print,
                  title: 'Print Report',
                  description: 'Send to a printer',
                  onTap: () {
                    Navigator.pop(context);
                    _printReport(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Helper method to build report options
  Widget _buildReportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4B3A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFFF4B3A)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // Method to generate and save PDF
  Future<void> _generateAndSavePdf(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFFFF4B3A)),
                const SizedBox(width: 20),
                Text(
                  "Generating report...",
                  style: GoogleFonts.lato(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Get transaction data
      final transactionsSnapshot = await _transactionStream.get();
      final transactions = transactionsSnapshot.docs;

      // Sort transactions
      transactions.sort((a, b) {
        DateTime dateA = (a['date'] as Timestamp).toDate();
        DateTime dateB = (b['date'] as Timestamp).toDate();
        return dateB.compareTo(dateA);
      });

      // Calculate summary
      double totalEarnings = 0;
      transactions.forEach((doc) {
        final data = doc.data();
        totalEarnings += (data['amount'] ?? 0).toDouble();
      });

      // Create PDF document
      final pdf = pw.Document();

      // Add content to the PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header:
              (context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'DeliGo - Transaction Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        DateFormat('dd MMM yyyy').format(DateTime.now()),
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  pw.Divider(),
                ],
              ),
          build:
              (context) => [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      margin: const pw.EdgeInsets.only(bottom: 20),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.orange100,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Summary',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total Earnings:'),
                              pw.Text(
                                '₹ ${totalEarnings.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total Transactions:'),
                              pw.Text(
                                '${transactions.length}',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.Text(
                      'Transaction Details',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(1),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(1),
                        3: const pw.FlexColumnWidth(1),
                      },
                      children: [
                        // Table header
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.orange50,
                          ),
                          children: [
                            _buildTableCell('Date & Time', isHeader: true),
                            _buildTableCell('Order Number', isHeader: true),
                            _buildTableCell('Payment Type', isHeader: true),
                            _buildTableCell('Amount', isHeader: true),
                          ],
                        ),
                        // Table data
                        ...transactions.map((doc) {
                          final data = doc.data();
                          DateTime dateTime =
                              (data['date'] as Timestamp).toDate();
                          String formattedDate = DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(dateTime);

                          return pw.TableRow(
                            children: [
                              _buildTableCell(formattedDate),
                              _buildTableCell(data['orderNumber'].toString()),
                              _buildTableCell(data['type'].toString()),
                              _buildTableCell(
                                'Rs ${data['amount'].toString()}',
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ],
          footer:
              (context) => pw.Column(
                children: [
                  pw.Divider(),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'DeliGo Earnings Report',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Page ${context.pageNumber} of ${context.pagesCount}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
        ),
      );

      // Save PDF
      final appDocDir = await getApplicationDocumentsDirectory();
      final pdfPath = '${appDocDir.path}/deligo_transaction_report.pdf';
      final file = File(pdfPath);
      await file.writeAsBytes(await pdf.save());

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report saved to documents', style: GoogleFonts.lato()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'VIEW',
            textColor: Colors.white,
            onPressed: () {
              // Open the PDF file (you'd need a PDF viewer package)
              // This is just a placeholder - implement with actual PDF viewer
              print('Opening PDF file at: $pdfPath');
            },
          ),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error generating report: $e',
            style: GoogleFonts.lato(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Method to print report
  Future<void> _printReport(BuildContext context) async {
    try {
      // Get transaction data
      final transactionsSnapshot = await _transactionStream.get();
      final transactions = transactionsSnapshot.docs;

      // Sort transactions
      transactions.sort((a, b) {
        DateTime dateA = (a['date'] as Timestamp).toDate();
        DateTime dateB = (b['date'] as Timestamp).toDate();
        return dateB.compareTo(dateA);
      });

      // Calculate summary
      double totalEarnings = 0;
      transactions.forEach((doc) {
        final data = doc.data();
        totalEarnings += (data['amount'] ?? 0).toDouble();
      });

      // Create PDF document
      final pdf = pw.Document();

      // Add content to the PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header:
              (context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'DeliGo - Transaction Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        DateFormat('dd MMM yyyy').format(DateTime.now()),
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  pw.Divider(),
                ],
              ),
          build:
              (context) => [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      margin: const pw.EdgeInsets.only(bottom: 20),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.orange100,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Summary',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total Earnings:'),
                              pw.Text(
                                'Rs ${totalEarnings.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total Transactions:'),
                              pw.Text(
                                '${transactions.length}',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.Text(
                      'Transaction Details',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(1),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(1),
                        3: const pw.FlexColumnWidth(1),
                      },
                      children: [
                        // Table header
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.orange50,
                          ),
                          children: [
                            _buildTableCell('Date & Time', isHeader: true),
                            _buildTableCell('Order Number', isHeader: true),
                            _buildTableCell('Payment Type', isHeader: true),
                            _buildTableCell('Amount', isHeader: true),
                          ],
                        ),
                        // Table data
                        ...transactions.map((doc) {
                          final data = doc.data();
                          DateTime dateTime =
                              (data['date'] as Timestamp).toDate();
                          String formattedDate = DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(dateTime);

                          return pw.TableRow(
                            children: [
                              _buildTableCell(formattedDate),
                              _buildTableCell(data['orderNumber'].toString()),
                              _buildTableCell(data['type'].toString()),
                              _buildTableCell(
                                'Rs ${data['amount'].toString()}',
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ],
          footer:
              (context) => pw.Column(
                children: [
                  pw.Divider(),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'DeliGo Earnings Report',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Page ${context.pageNumber} of ${context.pagesCount}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
        ),
      );

      // Launch print dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error printing report: $e', style: GoogleFonts.lato()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Helper for PDF table cells
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }
}
