import 'package:cloud_firestore/cloud_firestore.dart';

class ArtisanModel {
  final String uid;
  final String displayName;
  final String photoUrl;
  final String metier;
  final String metierLabel;
  final String metierEmoji;
  final String quartierPrincipal;
  final String statut;
  final bool isVerified;
  final String badge;
  final double notemoyenne;
  final int totalAvis;
  final int totalMissions;
  final bool isPremium;
  final String telephone;
  final List<String> photos;

  const ArtisanModel({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.metier,
    required this.metierLabel,
    required this.metierEmoji,
    required this.quartierPrincipal,
    required this.statut,
    this.isVerified = false,
    this.badge = 'standard',
    this.notemoyenne = 0.0,
    this.totalAvis = 0,
    this.totalMissions = 0,
    this.isPremium = false,
    this.telephone = '',
    this.photos = const [],
  });

  factory ArtisanModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ArtisanModel(
      uid: doc.id,
      displayName: d['displayName'] ?? '',
      photoUrl: d['photoUrl'] ?? '',
      metier: d['metier'] ?? '',
      metierLabel: d['metierLabel'] ?? '',
      metierEmoji: d['metierEmoji'] ?? '🔧',
      quartierPrincipal: d['quartierPrincipal'] ?? '',
      statut: d['statut'] ?? 'indispo',
      isVerified: d['isVerified'] ?? false,
      badge: d['badge'] ?? 'standard',
      notemoyenne: (d['notemoyenne'] ?? 0.0).toDouble(),
      totalAvis: d['totalAvis'] ?? 0,
      totalMissions: d['totalMissions'] ?? 0,
      isPremium: d['isPremium'] ?? false,
      telephone: d['telephone'] ?? '',
      photos: List<String>.from(d['photos'] ?? []),
    );
  }
}
