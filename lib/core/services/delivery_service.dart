import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_model.dart';

class DeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-Time Price Fetching (Requirement: Calculates price from ZonePrices collection)
  Future<double?> getEstimatedPrice(String pickup, String dropoff) async {
    try {
      // Logic: Look for exact route match in Firestore
      final query = await _firestore
          .collection('ZonePrices')
          .where('pickup', isEqualTo: pickup)
          .where('dropoff', isEqualTo: dropoff)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return (query.docs.first.data()['price'] as num).toDouble();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get list of available zones (Requirement: Zones collection)
  Future<List<String>> getZones() async {
    try {
      final query = await _firestore.collection('Zones').get();
      return query.docs.map((doc) => doc.data()['name'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  // Create a new delivery request (Denormalized)
  Future<void> createDelivery(Delivery delivery) async {
    final Map<String, dynamic> data = delivery.toMap();
    data['events'] = FieldValue.arrayUnion([
      {'type': 'created', 'at': Timestamp.now()}
    ]);
    await _firestore.collection('deliveries').add(data);
  }

  // Get stream of pending deliveries for riders
  Stream<List<Delivery>> getPendingDeliveries() {
    return _firestore
        .collection('deliveries')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Delivery.fromFirestore(doc)).toList());
  }

  // Get My Deliveries for Customer
  Stream<List<Delivery>> getCustomerDeliveries(String customerId) {
    return _firestore
        .collection('deliveries')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Delivery.fromFirestore(doc)).toList());
  }

  // Rider Job Concurrency Protection (Transaction)
  Future<bool> acceptJob(String deliveryId, String riderId, String riderPhone) async {
    return await _firestore.runTransaction((transaction) async {
      DocumentReference postRef = _firestore.collection('deliveries').doc(deliveryId);
      DocumentSnapshot snapshot = await transaction.get(postRef);

      if (!snapshot.exists) return false;

      String currentStatus = snapshot.get('status');
      if (currentStatus != 'pending') return false;

      transaction.update(postRef, {
        'riderId': riderId,
        'riderPhone': riderPhone,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
        'events': FieldValue.arrayUnion([
          {'type': 'accepted', 'at': Timestamp.now()}
        ]),
      });
      return true;
    });
  }

  // Professional Status Machine: Confirm Pickup
  Future<void> confirmPickup(String deliveryId, String photoUrl) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'status': 'picked',
      'pickupPhotoUrl': photoUrl,
      'pickupUploadedAt': FieldValue.serverTimestamp(),
      'events': FieldValue.arrayUnion([
        {'type': 'picked', 'at': Timestamp.now()}
      ]),
    });
  }

  // Professional Status Machine: Mark as Completed
  Future<void> confirmDelivery(String deliveryId, String photoUrl) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'status': 'completed',
      'dropoffPhotoUrl': photoUrl,
      'dropUploadedAt': FieldValue.serverTimestamp(),
      'events': FieldValue.arrayUnion([
        {'type': 'completed', 'at': Timestamp.now()}
      ]),
    });
  }
}
