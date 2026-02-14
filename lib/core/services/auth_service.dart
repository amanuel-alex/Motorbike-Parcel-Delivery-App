import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth changes
  Stream<User?> get user => _auth.authStateChanges();

  // Demo Mode Flag for Presentation
  static bool isDemoMode = false;

  // Sign in with phone number (Trigger)
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // Verify OTP
  Future<UserCredential?> signInWithOtp(String verificationId, String smsCode) async {
    // Presentation Bypass: Attempt Anonymous Auth for real persistence, fallback to mock if restricted
    if (smsCode == "888888" || smsCode == "123456") {
      isDemoMode = true;
      try {
        return await _auth.signInAnonymously();
      } catch (e) {
        return null; // Fallback: Proceed in Demo Mode without a real Firebase User
      }
    }

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user role
  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return (doc.data() as Map<String, dynamic>)['role'];
    }
    return null;
  }

  // Set user role and initial profile
  Future<void> setUserRole(String uid, String role, {String? phoneNumber}) async {
    await _firestore.collection('users').doc(uid).set({
      'role': role,
      'phoneNumber': phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'status': 'active',
    }, SetOptions(merge: true));
  }

  // Update last login metadata
  Future<void> updateMetadata(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  // Check if user has a profile
  Future<bool> userExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  // Get All Users (Admin)
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    });
  }
  // Helper for consistent IDs across Real and Demo modes
  String get currentUserUid {
    if (_auth.currentUser != null) return _auth.currentUser!.uid;
    return isDemoMode ? 'demo_guest_id' : 'unknown_user';
  }
  // Update user status (Admin)
  Future<void> updateUserStatus(String uid, String status) async {
    await _firestore.collection('users').doc(uid).update({
      'status': status,
    });
  }
}
