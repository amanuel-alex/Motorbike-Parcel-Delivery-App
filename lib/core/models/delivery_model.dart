import 'package:cloud_firestore/cloud_firestore.dart';

class Delivery {
  final String id;
  final String customerId;
  final String? riderId;
  final String pickupAddress;
  final String dropoffAddress;
  final String status; // pending, finding_rider, in_transit, delivered, canceled
  final double price;
  final String packageType;
  final DateTime createdAt;

  Delivery({
    required this.id,
    required this.customerId,
    this.riderId,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    required this.price,
    required this.packageType,
    required this.createdAt,
  });

  factory Delivery.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Delivery(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      riderId: data['riderId'],
      pickupAddress: data['pickupAddress'] ?? '',
      dropoffAddress: data['dropoffAddress'] ?? '',
      status: data['status'] ?? 'pending',
      price: (data['price'] ?? 0).toDouble(),
      packageType: data['packageType'] ?? 'Document',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'riderId': riderId,
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'status': status,
      'price': price,
      'packageType': packageType,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
