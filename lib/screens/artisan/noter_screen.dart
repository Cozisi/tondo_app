import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../models/artisan_model.dart';

class NoterScreen extends StatefulWidget {
  final ArtisanModel artisan;
  const NoterScreen({required this.artisan, super.key});

  @override
  State<NoterScreen> createState() => _NoterScreenState();
}

class _NoterScreenState extends State<NoterScreen> {
  int _note = 0;
  final _commentaireController = TextEditingController();
  bool _enChargement = false;
  bool _envoye = false;

  Future<void> _soumettre() async {
    if (_note == 0) return;
    setState(() => _enChargement = true);

    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('reviews').add({
      'artisanId': widget.artisan.uid,
      'clientId': user?.uid ?? '',
      'note': _note,
      'commentaire': _commentaireController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'isVisible': true,
      'source': 'app',
    });

    setState(() {
      _envoye = true;
      _enChargement = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const Text('Laisser un avis',
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w700,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _envoye ? _succes() : _formulaire(),
      ),
    );
  }

  Widget _succes() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text('Merci pour votre avis !',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              )),
          const SizedBox(height: 8),
          Text('Votre avis aide la communauté Tondo.',
              style: TextStyle(color: AppColors.mid)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99)),
            ),
            child: const Text('Retour',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _formulaire() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Artisan
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(widget.artisan.metierEmoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.artisan.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.black,
                    )),
                Text(widget.artisan.metierLabel,
                    style: const TextStyle(color: AppColors.mid)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Étoiles
        const Text('Votre note',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.black,
            )),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final etoile = i + 1;
            return GestureDetector(
              onTap: () => setState(() => _note = etoile),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.star_rounded,
                  size: 48,
                  color: etoile <= _note
                      ? const Color(0xFFF59E0B)
                      : AppColors.border,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _note == 0
                ? 'Touchez une étoile'
                : _note == 1
                    ? '😞 Très mauvais'
                    : _note == 2
                        ? '😐 Mauvais'
                        : _note == 3
                            ? '🙂 Correct'
                            : _note == 4
                                ? '😊 Bien'
                                : '🤩 Excellent !',
            style: TextStyle(
              color: _note == 0 ? AppColors.mid : AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Commentaire
        const Text('Commentaire (facultatif)',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.black,
            )),
        const SizedBox(height: 8),
        TextField(
          controller: _commentaireController,
          maxLines: 4,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: 'Décrivez votre expérience...',
            hintStyle: TextStyle(color: AppColors.mid),
            filled: true,
            fillColor: AppColors.gray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const Spacer(),

        // Bouton soumettre
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _note == 0 || _enChargement ? null : _soumettre,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              disabledBackgroundColor: AppColors.border,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99)),
            ),
            child: _enChargement
                ? const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2)
                : const Text('Publier mon avis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )),
          ),
        ),
      ],
    );
  }
}
