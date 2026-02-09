import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryEvent {
  final String type;
  final DateTime at;

  DeliveryEvent({required this.type, required this.at});

  factory DeliveryEvent.fromMap(Map<String, dynamic> data) {
    return DeliveryEvent(
      type: data['type'] ?? 'unknown',
      at: (data['at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'at': Timestamp.fromDate(at),
    };
  }
}

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
  final List<DeliveryEvent> events;

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

  // Manual payment verification fields
  final String? paymentRef;
  final String? paymentStatus; // pending -> approved -> canceled
  final String? paymentProvider;
  final String? paymentScreenshotUrl;

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
    this.events = const [],
    this.pickupZoneName,
    this.dropZoneName,
    this.customerPhone,
    this.riderPhone,
    this.pickupPhotoUrl,
    this.dropoffPhotoUrl,
    this.pickupUploadedAt,
    this.dropUploadedAt,
    this.paymentRef,
    this.paymentStatus,
    this.paymentProvider,
    this.paymentScreenshotUrl,
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
      events: (data['events'] as List? ?? [])
          .map((e) => DeliveryEvent.fromMap(e as Map<String, dynamic>))
          .toList(),
      pickupZoneName: data['pickupZoneName'],
      dropZoneName: data['dropZoneName'],
      customerPhone: data['customerPhone'],
      riderPhone: data['riderPhone'],
      pickupPhotoUrl: data['pickupPhotoUrl'],
      dropoffPhotoUrl: data['dropoffPhotoUrl'],
      pickupUploadedAt: (data['pickupUploadedAt'] as Timestamp?)?.toDate(),
      dropUploadedAt: (data['dropUploadedAt'] as Timestamp?)?.toDate(),
      paymentRef: data['paymentRef'],
      paymentStatus: data['paymentStatus'],
      paymentProvider: data['paymentProvider'],
      paymentScreenshotUrl: data['paymentScreenshotUrl'],
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
      'events': events.map((e) => e.toMap()).toList(),
      'pickupZoneName': pickupZoneName,
      'dropZoneName': dropZoneName,
      'customerPhone': customerPhone,
      'riderPhone': riderPhone,
      'pickupPhotoUrl': pickupPhotoUrl,
      'dropoffPhotoUrl': dropoffPhotoUrl,
      'pickupUploadedAt': pickupUploadedAt != null ? Timestamp.fromDate(pickupUploadedAt!) : null,
      'dropUploadedAt': dropUploadedAt != null ? Timestamp.fromDate(dropUploadedAt!) : null,
      'paymentRef': paymentRef,
      'paymentStatus': paymentStatus,
      'paymentProvider': paymentProvider,
      'paymentScreenshotUrl': paymentScreenshotUrl,
    };
  }
}
