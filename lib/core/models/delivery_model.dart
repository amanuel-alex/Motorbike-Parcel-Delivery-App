import 'package:cloud_firestore/cloud_firestore.dart';

class Delivery {
  final String id;
  final String customerId;
  final String? riderId;
  final String pickupAddress;
  final String dropoffAddress;
  final String status; // pending -> accepted -> picked -> completed
  final double price;
  final String packageType;
  final DateTime createdAt;

  // Denormalized Fields (Pro Moves)
  final String? pickupZoneName;
  final String? dropZoneName;
  final String? customerPhone;
  final String? riderPhone;

  // Photo & Proof Fields
  final String? pickupPhotoUrl;
  final String? dropoffPhotoUrl;
  final DateTime? pickupUploadedAt;
  final DateTime? dropUploadedAt;

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
    this.pickupZoneName,
    this.dropZoneName,
    this.customerPhone,
    this.riderPhone,
    this.pickupPhotoUrl,
    this.dropoffPhotoUrl,
    this.pickupUploadedAt,
    this.dropUploadedAt,
  });

  factory Delivery.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Delivery(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      riderId: data['riderId'],
      pickupAddress: data['pickupAddress'] ?? '',
      dropoffAddress: data['dropoffAddress'] ?? '',
      status: data['status'] ?? 'pending',
      price: (data['price'] ?? 0).toDouble(),
      packageType: data['packageType'] ?? 'Document',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pickupZoneName: data['pickupZoneName'],
      dropZoneName: data['dropZoneName'],
      customerPhone: data['customerPhone'],
      riderPhone: data['riderPhone'],
      pickupPhotoUrl: data['pickupPhotoUrl'],
      dropoffPhotoUrl: data['dropoffPhotoUrl'],
      pickupUploadedAt: (data['pickupUploadedAt'] as Timestamp?)?.toDate(),
      dropUploadedAt: (data['dropUploadedAt'] as Timestamp?)?.toDate(),
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
      'pickupZoneName': pickupZoneName,
      'dropZoneName': dropZoneName,
      'customerPhone': customerPhone,
      'riderPhone': riderPhone,
      'pickupPhotoUrl': pickupPhotoUrl,
      'dropoffPhotoUrl': dropoffPhotoUrl,
      'pickupUploadedAt': pickupUploadedAt != null ? Timestamp.fromDate(pickupUploadedAt!) : null,
      'dropUploadedAt': dropUploadedAt != null ? Timestamp.fromDate(dropUploadedAt!) : null,
    };
  }
}
