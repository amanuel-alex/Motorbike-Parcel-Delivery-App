import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_model.dart';

class DeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new delivery request
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

  // Accept a job
  Future<void> acceptJob(String deliveryId, String riderId) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'riderId': riderId,
      'status': 'finding_rider', // Or 'accepted'
    });
  }

  // Update status (Pickup, Delivery)
  Future<void> updateDeliveryStatus(String deliveryId, String status) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'status': status,
    });
  }
}
