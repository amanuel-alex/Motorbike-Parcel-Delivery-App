import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'auth_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage and returns the download URL.
  Future<String> uploadDeliveryPhoto({
    required File file,
    required String deliveryId,
    required String type, // 'pickup' or 'dropoff'
  }) async {
    if (AuthService.isDemoMode) {
      // Return a professional placeholder for Demo/Walkthrough
      return 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?auto=format&fit=crop&q=80&w=800';
    }

    try {
      final String fileName = '${type}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final Reference ref = _storage.ref().child('deliveries').child(deliveryId).child(fileName);
      
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (AuthService.isDemoMode) {
        return 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?auto=format&fit=crop&q=80&w=800';
      }
      throw Exception('Failed to upload photo: $e');
    }
  }

  /// Uploads a payment screenshot.
  Future<String> uploadPaymentScreenshot({
    required File file,
    required String deliveryId,
  }) async {
    if (AuthService.isDemoMode) {
      return 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&q=80&w=800';
    }

    try {
      final String fileName = 'payment_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final Reference ref = _storage.ref().child('payments').child(deliveryId).child(fileName);
      
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (AuthService.isDemoMode) {
        return 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&q=80&w=800';
      }
      throw Exception('Failed to upload payment screenshot: $e');
    }
  }
}
