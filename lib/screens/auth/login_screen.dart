import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _enChargement = false;
  String? _role;
  String? _erreur;

  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _continuer() async {
    if (_role == null) {
      setState(() => _erreur = 'Choisissez votre profil d\'abord');
      return;
    }

    if (_role == 'client') {
      if (_prenomController.text.trim().isEmpty ||
          _nomController.text.trim().isEmpty) {
        setState(() => _erreur = 'Veuillez remplir votre nom et prénom');
        return;
      }
    }

    setState(() {
      _enChargement = true;
      _erreur = null;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        final cred = await FirebaseAuth.instance.signInAnonymously();
        user = cred.user;
      }

      if (user == null) {
        setState(() {
          _erreur = 'Erreur de connexion. Réessayez.';
          _enChargement = false;
        });
        return;
      }

      final data = {
        'role': _role,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_role == 'client') {
        data['prenom'] = _prenomController.text.trim();
        data['nom'] = _nomController.text.trim();
        if (_telephoneController.text.trim().isNotEmpty) {
          data['telephone'] = _telephoneController.text.trim();
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      if (mounted)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
    } catch (e) {
      setState(() {
        _erreur = 'Erreur : ${e.toString()}';
        _enChargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tondo',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.red,
                )),
            const SizedBox(height: 8),
            const Text('Vous êtes ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                )),
            const Text('Choisissez votre profil pour continuer',
                style: TextStyle(fontSize: 14, color: AppColors.mid)),
            const SizedBox(height: 32),

            // CHOIX RÔLE
            Row(
              children: [
                Expanded(
                  child: _roleCard(
                    emoji: '👤',
                    label: 'Client',
                    description: 'Je cherche un artisan',
                    selected: _role == 'client',
                    onTap: () => setState(() => _role = 'client'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _roleCard(
                    emoji: '🔧',
                    label: 'Artisan',
                    description: 'Je propose mes services',
                    selected: _role == 'artisan',
                    onTap: () => setState(() => _role = 'artisan'),
                  ),
                ),
              ],
            ),

            // FORMULAIRE CLIENT
            if (_role == 'client') ...[
              const SizedBox(height: 28),
              const Text('Vos informations',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  )),
              const SizedBox(height: 12),
              _champSaisie(
                controller: _prenomController,
                hint: 'Prénom *',
                icone: Icons.person_outline,
              ),
              const SizedBox(height: 10),
              _champSaisie(
                controller: _nomController,
                hint: 'Nom *',
                icone: Icons.person_outline,
              ),
              const SizedBox(height: 10),
              _champSaisie(
                controller: _telephoneController,
                hint: 'Téléphone (optionnel)',
                icone: Icons.phone_outlined,
                clavier: TextInputType.phone,
              ),
            ],

            // FORMULAIRE ARTISAN
            if (_role == 'artisan') ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.redLight,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.red.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Text('ℹ️', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Votre profil artisan sera créé et vérifié par l\'équipe Tondo avant d\'être visible.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.red,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_erreur != null) ...[
              const SizedBox(height: 16),
              Text(_erreur!,
                  style: const TextStyle(color: AppColors.red, fontSize: 13)),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _enChargement ? null : _continuer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99)),
                  disabledBackgroundColor: AppColors.border,
                ),
                child: _enChargement
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : const Text('Continuer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        )),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Plus tard',
                    style: TextStyle(color: AppColors.mid)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _champSaisie({
    required TextEditingController controller,
    required String hint,
    required IconData icone,
    TextInputType clavier = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: clavier,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.mid, fontSize: 14),
          prefixIcon: Icon(icone, color: AppColors.mid, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget _roleCard({
    required String emoji,
    required String label,
    required String description,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.red.withValues(alpha: 0.06) : AppColors.gray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.red : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: selected ? AppColors.red : AppColors.black,
                )),
            const SizedBox(height: 4),
            Text(description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mid,
                )),
          ],
        ),
      ),
    );
  }
}
