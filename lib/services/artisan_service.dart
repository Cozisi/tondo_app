import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artisan_model.dart';

class ArtisanService {
  final _db = FirebaseFirestore.instance;

  Stream<List<ArtisanModel>> getArtisansDisponibles() {
    return _db
        .collection('artisans')
        .where('statut', isEqualTo: 'disponible')
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ArtisanModel.fromFirestore(doc)).toList());
  }

  Stream<List<ArtisanModel>> getArtisansByMetier(String metier) {
    return _db
        .collection('artisans')
        .where('metier', isEqualTo: metier)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ArtisanModel.fromFirestore(doc)).toList());
  }
}
