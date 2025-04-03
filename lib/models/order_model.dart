class Order {
  final String id;
  final String customerName;
  final String delivery;
  final DateTime orderDate;
  final List<Map<String, dynamic>> orderedItems;
  final double subTotal;
  final double deliveryCost;
  final double totalCost;
  String status;
  final String paymentMethod;
  final String deliveryLocation;
  final double distance;
  final String mobile;
  final String partnerId;

  Order({
    required this.id,
    required this.customerName,
    required this.delivery,
    required this.orderDate,
    required this.orderedItems,
    required this.subTotal,
    required this.deliveryCost,
    required this.totalCost,
    required this.status,
    required this.paymentMethod,
    required this.deliveryLocation,
    required this.distance,
    required this.mobile,
    required this.partnerId,
  });
}