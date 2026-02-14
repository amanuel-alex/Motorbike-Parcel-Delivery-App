import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/delivery_model.dart';
import '../models/chat_message.dart';
import 'auth_service.dart';

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

  // Get streaming list of available zones
  Stream<List<String>> getZonesStream() {
    return _firestore.collection('Zones').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
    });
  }

  Future<String> createDelivery(Delivery delivery) async {
    final Map<String, dynamic> data = delivery.toMap();
    // Logic: Set expected time to 30 mins from now (Mock)
    data['expectedDeliveryTime'] = Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 30)));
    data['events'] = FieldValue.arrayUnion([
      {'type': 'created', 'at': Timestamp.now()}
    ]);

    try {
      final docRef = await _firestore.collection('deliveries')
          .add(data)
          .timeout(const Duration(seconds: 8));
      return docRef.id;
    } catch (e) {
      if (e is TimeoutException) {
        throw 'Network Timeout: Your request is saved locally but could not reach the server. Please check your connection.';
      }
      rethrow;
    }
  }

  // Submit Payment Proof (Requirement: Confirm payment)
  Future<void> submitPaymentProof({
    required String deliveryId,
    required String paymentRef,
    required String provider,
    String? screenshotUrl,
  }) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'paymentRef': paymentRef,
      'paymentProvider': provider,
      'paymentScreenshotUrl': screenshotUrl,
      'paymentStatus': 'pending', // Boss must approve
      'events': FieldValue.arrayUnion([
        {
          'type': 'payment_submitted',
          'at': Timestamp.now(),
          'ref': paymentRef,
          'provider': provider,
          'hasScreenshot': screenshotUrl != null,
        }
      ]),
    });
  }

  // Update Payment Status (For Boss/Admin)
  Future<void> updatePaymentStatus(String deliveryId, String status) async {
    final Map<String, dynamic> updates = {
      'paymentStatus': status,
    };
    
    final List<Map<String, dynamic>> events = [
      {'type': 'payment_$status', 'at': Timestamp.now()}
    ];

    if (status == 'canceled') {
      updates['status'] = 'canceled';
      events.add({'type': 'canceled', 'at': Timestamp.now(), 'reason': 'Payment Rejected'});
    }
    
    updates['events'] = FieldValue.arrayUnion(events);

    await _firestore.collection('deliveries').doc(deliveryId).update(updates);
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
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((doc) => Delivery.fromFirestore(doc)).toList();
          // Sort in-memory to maintain reverse chronological order without index requirement
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
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

      // Update Rider Stats
      transaction.update(_firestore.collection('users').doc(riderId), {
        'totalDeliveries': FieldValue.increment(1),
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
    return await _firestore.runTransaction((transaction) async {
      DocumentReference delRef = _firestore.collection('deliveries').doc(deliveryId);
      DocumentSnapshot delSnap = await transaction.get(delRef);
      
      if (!delSnap.exists) return;
      
      final riderId = delSnap.get('riderId');
      
      transaction.update(delRef, {
        'status': 'completed',
        'dropoffPhotoUrl': photoUrl,
        'dropUploadedAt': FieldValue.serverTimestamp(),
        'events': FieldValue.arrayUnion([
          {'type': 'completed', 'at': Timestamp.now()}
        ]),
      });

      if (riderId != null) {
        transaction.update(_firestore.collection('users').doc(riderId as String), {
          'completedDeliveries': FieldValue.increment(1),
        });
      }
    });
  }

  // Customer confirms receipt
  Future<void> confirmReceipt(String deliveryId) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'customerConfirmedAt': FieldValue.serverTimestamp(),
      'events': FieldValue.arrayUnion([
        {'type': 'customer_confirmed', 'at': Timestamp.now()}
      ]),
    });
  }

  // Admin pays rider
  Future<void> payRider(String deliveryId, double amount) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'riderPaid': true,
      'riderPayoutAmount': amount,
      'events': FieldValue.arrayUnion([
        {'type': 'rider_paid', 'at': Timestamp.now(), 'amount': amount}
      ]),
    });
  }

  // Get Single Delivery Stream
  Stream<Delivery> getDeliveryStream(String deliveryId) {
    return _firestore
        .collection('deliveries')
        .doc(deliveryId)
        .snapshots()
        .map((doc) => Delivery.fromFirestore(doc));
  }

  // Get All Deliveries for Admin (Simplified query for visibility)
  Stream<List<Delivery>> getAllDeliveries() {
    return _firestore.collection('deliveries')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Delivery.fromFirestore(doc)).toList());
  }

  // Get Deliveries for a specific Rider
  Stream<List<Delivery>> getRiderDeliveries(String riderId) {
    return _firestore.collection('deliveries')
        .where('riderId', isEqualTo: riderId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Delivery.fromFirestore(doc)).toList());
  }

  // Cancel Delivery (Customer/Admin)
  Future<void> cancelDelivery(String deliveryId) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'status': 'canceled',
      'events': FieldValue.arrayUnion([
        {'type': 'canceled', 'at': Timestamp.now()}
      ]),
    });
  }

  // Update Delivery Price (Admin Override)
  Future<void> updateDeliveryPrice(String deliveryId, double newPrice) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'price': newPrice,
      'events': FieldValue.arrayUnion([
        {'type': 'price_updated', 'at': Timestamp.now(), 'newPrice': newPrice}
      ]),
    });
  }

  // --- ADMIN DASHBOARD ---

  Stream<Map<String, dynamic>> getAdminStats() {
    return _firestore.collection('deliveries').snapshots().asyncMap((deliverySnapshot) async {
      final userSnapshot = await _firestore.collection('users').get();
      
      final deliveries = deliverySnapshot.docs.map((doc) => Delivery.fromFirestore(doc)).toList();
      final users = userSnapshot.docs;
      
      final pendingCount = deliveries.where((d) => d.status == 'pending').length;
      final completedCount = deliveries.where((d) => d.status == 'completed').length;
      final riderCount = users.where((u) => u.data()['role'] == 'rider').length;
      final customerCount = users.where((u) => u.data()['role'] == 'customer').length;
      
      double totalRevenue = 0;
      for (var d in deliveries) {
        if (d.status == 'completed') totalRevenue += d.price;
      }
      
      return {
        'totalDeliveries': deliveries.length,
        'pendingDeliveries': pendingCount,
        'completedDeliveries': completedCount,
        'totalRiders': riderCount,
        'totalCustomers': customerCount,
        'totalRevenue': totalRevenue,
      };
    });
  }

  // --- Zone Management (Dynamic) ---

  // Add a new Zone
  Future<void> addZone(String zoneName) async {
    // Check if exists first to avoid duplicates
    final snapshot = await _firestore.collection('Zones').where('name', isEqualTo: zoneName).get();
    if (snapshot.docs.isNotEmpty) return;

    await _firestore.collection('Zones').add({
      'name': zoneName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Add Price Rule
  Future<void> addZonePrice(String pickup, String dropoff, double price) async {
    // Check if rule exists
    final snapshot = await _firestore.collection('ZonePrices')
        .where('pickup', isEqualTo: pickup)
        .where('dropoff', isEqualTo: dropoff)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Update existing
      await _firestore.collection('ZonePrices').doc(snapshot.docs.first.id).update({'price': price});
    } else {
      // Create new
      await _firestore.collection('ZonePrices').add({
        'pickup': pickup,
        'dropoff': dropoff,
        'price': price,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get Price Rules (Admin)
  Stream<List<Map<String, dynamic>>> getZonePricesStream() {
    return _firestore.collection('ZonePrices').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Update Price Rule
  Future<void> updateZonePrice(String id, double price) async {
    await _firestore.collection('ZonePrices').doc(id).update({'price': price});
  }

  // Delete Price Rule
  Future<void> deleteZonePrice(String id) async {
    await _firestore.collection('ZonePrices').doc(id).delete();
  }

  // Request New Zone (Customer)
  Future<void> requestNewZone(String zoneName) async {
    await _firestore.collection('ZoneRequests').add({
      'name': zoneName,
      'requestedAt': FieldValue.serverTimestamp(),
      'status': 'pending', 
    });
  }

  // Get Zone Requests (Admin)
  Stream<List<Map<String, dynamic>>> getZoneRequests() {
    return _firestore.collection('ZoneRequests')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // Approve Zone Request
  Future<void> approveZoneRequest(String requestId, String zoneName) async {
    await addZone(zoneName); // Add to official list
    await _firestore.collection('ZoneRequests').doc(requestId).delete(); // Remove request
  }

  // Reject Zone Request
  Future<void> rejectZoneRequest(String requestId) async {
    await _firestore.collection('ZoneRequests').doc(requestId).delete();
  }

  // --- Chat System ---

  Future<void> sendMessage(String deliveryId, ChatMessage message) async {
    await _firestore
        .collection('deliveries')
        .doc(deliveryId)
        .collection('messages')
        .add(message.toMap());
  }

  Stream<List<ChatMessage>> getChatMessages(String deliveryId) {
    return _firestore
        .collection('deliveries')
        .doc(deliveryId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }
}
