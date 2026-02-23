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

  Future<void> _continuer() async {
    if (_role == null) {
      setState(() => _erreur = 'Choisissez votre profil d\'abord');
      return;
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

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'role': _role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
    } catch (e) {
      setState(() {
        _erreur = 'Erreur. Réessayez.';
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
      body: Padding(
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
            if (_erreur != null) ...[
              const SizedBox(height: 16),
              Text(_erreur!,
                  style: const TextStyle(color: AppColors.red, fontSize: 13)),
            ],
            const Spacer(),
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
