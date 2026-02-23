import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Future<String?> getRole() async {
    final data = await getUserData();
    return data?['role'];
  }

  Future<DocumentSnapshot?> getArtisanProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    // Cherche par uid
    final snap = await _db
        .collection('artisans')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) return snap.docs.first;
    return null;
  }
}
