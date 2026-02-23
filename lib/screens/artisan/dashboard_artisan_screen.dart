import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tondo/screens/auth/welcome_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../services/cloudinary_service.dart';

class DashboardArtisanScreen extends StatefulWidget {
  final String artisanId;
  final Map<String, dynamic> data;
  final VoidCallback onDeconnecter;

  const DashboardArtisanScreen({
    required this.artisanId,
    required this.data,
    required this.onDeconnecter,
    super.key,
  });

  @override
  State<DashboardArtisanScreen> createState() => _DashboardArtisanScreenState();
}

class _DashboardArtisanScreenState extends State<DashboardArtisanScreen> {
  final _cloudinary = CloudinaryService();
  final _picker = ImagePicker();
  bool _uploadingPhoto = false;
  bool _uploadingBanniere = false;
  bool _uploadingRealisation = false;

  Future<void> _uploadPhotoProfile() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    final url = await _cloudinary.uploadImage(File(picked.path));
    if (url != null) {
      await FirebaseFirestore.instance
          .collection('artisans')
          .doc(widget.artisanId)
          .update({'photoUrl': url});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo de profil mise à jour ✅'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    }
    if (mounted) setState(() => _uploadingPhoto = false);
  }

  Future<void> _uploadBanniere() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() => _uploadingBanniere = true);
    final url = await _cloudinary.uploadImage(File(picked.path));
    if (url != null) {
      await FirebaseFirestore.instance
          .collection('artisans')
          .doc(widget.artisanId)
          .update({'banniereUrl': url});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bannière mise à jour ✅'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    }
    if (mounted) setState(() => _uploadingBanniere = false);
  }

  Future<void> _uploadRealisation() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() => _uploadingRealisation = true);
    final url = await _cloudinary.uploadImage(File(picked.path));
    if (url != null) {
      final photos = List<String>.from(widget.data['photos'] ?? []);
      photos.add(url);
      await FirebaseFirestore.instance
          .collection('artisans')
          .doc(widget.artisanId)
          .update({'photos': photos});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo de réalisation ajoutée ✅'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    }
    if (mounted) setState(() => _uploadingRealisation = false);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('artisans')
          .doc(widget.artisanId)
          .snapshots(),
      builder: (context, snapshot) {
        final liveData = snapshot.data?.data() as Map<String, dynamic>? ?? data;
        final photos = List<String>.from(liveData['photos'] ?? []);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              const Text('Mon Tableau de Bord',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  )),
              const SizedBox(height: 4),
              Text(
                FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
                style: const TextStyle(color: AppColors.mid, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // PROFIL
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: liveData['photoUrl'] != null &&
                              liveData['photoUrl'].isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(liveData['photoUrl'],
                                  fit: BoxFit.cover),
                            )
                          : Center(
                              child: Text(liveData['metierEmoji'] ?? '🔧',
                                  style: const TextStyle(fontSize: 28)),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(liveData['displayName'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.black,
                              )),
                          Text(liveData['metierLabel'] ?? '',
                              style: const TextStyle(
                                color: AppColors.mid,
                                fontSize: 13,
                              )),
                        ],
                      ),
                    ),
                    if (liveData['isVerified'] == true)
                      const Icon(Icons.verified,
                          color: AppColors.green, size: 22),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // STATS
              Row(
                children: [
                  Expanded(
                      child: _statCard(
                          '⭐', '${liveData['notemoyenne'] ?? 0}', 'Note')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _statCard(
                          '💬', '${liveData['totalAvis'] ?? 0}', 'Avis')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _statCard('✅', '${liveData['totalMissions'] ?? 0}',
                          'Missions')),
                ],
              ),
              const SizedBox(height: 12),

              // DISPONIBILITÉ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Disponibilité',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.black,
                            )),
                        Text(
                          liveData['statut'] == 'disponible'
                              ? 'Visible par les clients'
                              : 'Masqué des recherches',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mid,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: liveData['statut'] == 'disponible',
                      activeColor: AppColors.green,
                      onChanged: (val) async {
                        await FirebaseFirestore.instance
                            .collection('artisans')
                            .doc(widget.artisanId)
                            .update({'statut': val ? 'disponible' : 'indispo'});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // PHOTOS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Photos du profil',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.black,
                        )),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _uploadBtn(
                            label: 'Photo profil',
                            icon: Icons.person,
                            loading: _uploadingPhoto,
                            onTap: _uploadPhotoProfile,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _uploadBtn(
                            label: 'Bannière',
                            icon: Icons.image,
                            loading: _uploadingBanniere,
                            onTap: _uploadBanniere,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // RÉALISATIONS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mes réalisations',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.black,
                            )),
                        Text('${photos.length} photo(s)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mid,
                            )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (photos.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: photos.length,
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(photos[i], fit: BoxFit.cover),
                        ),
                      ),
                    const SizedBox(height: 12),
                    _uploadBtn(
                      label: 'Ajouter une réalisation',
                      icon: Icons.add_photo_alternate,
                      loading: _uploadingRealisation,
                      onTap: _uploadRealisation,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _uploadBtn({
    required String label,
    required IconData icon,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.gray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.red,
                    ),
                  )
                : Icon(icon, size: 18, color: AppColors.red),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.black,
              )),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.mid)),
          OutlinedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await FirebaseAuth.instance.signInAnonymously();
              if (context.mounted)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (_) => false,
                );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99)),
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}
