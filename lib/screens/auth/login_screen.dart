import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _enChargement = false;
  bool _codEnvoye = false;
  String? _verificationId;
  String? _erreur;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _envoyerCode() async {
    final phone = '+226${_phoneController.text.replaceAll(' ', '')}';
    if (phone.length < 12) {
      setState(() => _erreur = 'Numéro invalide');
      return;
    }
    setState(() {
      _enChargement = true;
      _erreur = null;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (cred) async {
        await _connecter(cred);
      },
      verificationFailed: (e) {
        setState(() {
          _erreur = 'Erreur : ${e.message}';
          _enChargement = false;
        });
      },
      codeSent: (verificationId, _) {
        setState(() {
          _verificationId = verificationId;
          _codEnvoye = true;
          _enChargement = false;
        });
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> _verifierCode() async {
    if (_verificationId == null) return;
    setState(() {
      _enChargement = true;
      _erreur = null;
    });
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      await _connecter(cred);
    } catch (e) {
      setState(() {
        _erreur = 'Code incorrect. Réessayez.';
        _enChargement = false;
      });
    }
  }

  Future<void> _connecter(PhoneAuthCredential cred) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.isAnonymous) {
      await user.linkWithCredential(cred);
    } else {
      await FirebaseAuth.instance.signInWithCredential(cred);
    }
    if (mounted) Navigator.pop(context);
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
            Text(
              _codEnvoye
                  ? 'Entrez le code reçu par SMS'
                  : 'Entrez votre numéro de téléphone',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            Text(
              _codEnvoye
                  ? 'Code envoyé au +226 ${_phoneController.text}'
                  : 'Vous recevrez un code SMS pour confirmer',
              style: const TextStyle(fontSize: 14, color: AppColors.mid),
            ),
            const SizedBox(height: 32),

            // CHAMP NUMÉRO
            if (!_codEnvoye)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.gray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: const Text('+226',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          )),
                    ),
                    Container(width: 1, height: 24, color: AppColors.border),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '70 XX XX XX',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // CHAMP CODE OTP
            if (_codEnvoye)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.gray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                  ),
                  maxLength: 6,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '------',
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

            if (_erreur != null) ...[
              const SizedBox(height: 8),
              Text(_erreur!,
                  style: const TextStyle(color: AppColors.red, fontSize: 13)),
            ],

            const SizedBox(height: 24),

            // BOUTON PRINCIPAL
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _enChargement
                    ? null
                    : (_codEnvoye ? _verifierCode : _envoyerCode),
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
                    : Text(
                        _codEnvoye
                            ? 'Confirmer le code'
                            : 'Envoyer le code SMS',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        )),
              ),
            ),

            if (_codEnvoye) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _codEnvoye = false;
                    _otpController.clear();
                    _erreur = null;
                  }),
                  child: const Text('Changer de numéro',
                      style: TextStyle(color: AppColors.mid)),
                ),
              ),
            ],

            const Spacer(),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continuer sans compte',
                    style: TextStyle(color: AppColors.mid)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
