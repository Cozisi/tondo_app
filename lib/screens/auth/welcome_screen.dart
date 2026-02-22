import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';
import 'package:tondo/main.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),

              // LOGO
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text('🔗', style: TextStyle(fontSize: 44)),
                ),
              ),
              const SizedBox(height: 24),

              // NOM
              const Text('Tondo',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  )),
              const SizedBox(height: 8),
              const Text('Ensemble, on construit.',
                  style: TextStyle(fontSize: 16, color: Colors.white60)),
              const SizedBox(height: 16),

              // DESCRIPTION
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Trouvez un artisan vérifié à Ouagadougou en 3 clics. Plombiers, électriciens, menuisiers — disponibles maintenant.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),
              ),

              const Spacer(),

              // BOUTON S'INSCRIRE
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99)),
                  ),
                  child: const Text('S\'inscrire / Se connecter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ),
              const SizedBox(height: 12),

              // BOUTON CONTINUER SANS COMPTE
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99)),
                  ),
                  child: const Text('Continuer sans compte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Gratuit · Sans engagement',
                  style: TextStyle(fontSize: 12, color: Colors.white30)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
