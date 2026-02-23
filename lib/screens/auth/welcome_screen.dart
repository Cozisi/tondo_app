import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';
import 'package:tondo/main.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // LOGO SVG
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.red.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: CustomPaint(
                  painter: _TondoLogoPainter(),
                ),
              ),
              const SizedBox(height: 28),

              // NOM
              const Text('Tondo',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -2,
                  )),
              const SizedBox(height: 8),

              // SLOGAN
              const Text('Ensemble, on construit.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white60,
                    letterSpacing: 0.5,
                  )),
              const SizedBox(height: 8),

              // BARRE TRICOLORE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _barreColor(AppColors.red),
                  const SizedBox(width: 4),
                  _barreColor(AppColors.green),
                  const SizedBox(width: 4),
                  _barreColor(AppColors.blue),
                ],
              ),
              const SizedBox(height: 32),

              // DESCRIPTION
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: const Text(
                  'Trouvez un artisan partout à Burkina Faso en 3 clics. Plombiers, électriciens, menuisiers et autres.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                    height: 1.6,
                  ),
                ),
              ),

              const Spacer(flex: 3),

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
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('S\'inscrire / Se connecter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      )),
                ),
              ),
              const SizedBox(height: 12),

              // BOUTON CONTINUER
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Continuer sans compte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      )),
                ),
              ),
              const SizedBox(height: 16),

              // MENTION
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline, size: 12, color: Colors.white24),
                  SizedBox(width: 4),
                  Text('Gratuit · Sans engagement · Burkina Faso',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white24,
                      )),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barreColor(Color color) {
    return Container(
      width: 24,
      height: 3,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

// LOGO TONDO — 3 nœuds connectés
class _TondoLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Points des 3 nœuds
    final top = Offset(cx, cy - 22);
    final bottomLeft = Offset(cx - 20, cy + 16);
    final bottomRight = Offset(cx + 20, cy + 16);

    // Lignes de connexion
    canvas.drawLine(top, bottomLeft, linePaint);
    canvas.drawLine(top, bottomRight, linePaint);

    // Nœud central (plus grand)
    canvas.drawCircle(top, 10, paint);

    // Nœuds secondaires
    final paint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(bottomLeft, 8, paint2);
    canvas.drawCircle(bottomRight, 8, paint2);
  }

  @override
  bool shouldRepaint(_) => false;
}
