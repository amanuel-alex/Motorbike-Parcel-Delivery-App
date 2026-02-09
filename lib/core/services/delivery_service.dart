import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_model.dart';

class DeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new delivery request (Denormalized)
  Future<void> createDelivery(Delivery delivery) async {
    await _firestore.collection('deliveries').add(delivery.toMap());
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
    });
  }

  // Professional Status Machine: Mark as Completed
  Future<void> confirmDelivery(String deliveryId, String photoUrl) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'status': 'completed',
      'dropoffPhotoUrl': photoUrl,
      'dropUploadedAt': FieldValue.serverTimestamp(),
    });
  }
}
