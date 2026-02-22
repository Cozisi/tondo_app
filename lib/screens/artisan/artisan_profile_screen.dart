import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/artisan_model.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../artisan/noter_screen.dart';

class ArtisanProfileScreen extends StatelessWidget {
  final ArtisanModel artisan;
  const ArtisanProfileScreen({required this.artisan, super.key});

  Future<void> _appeler() async {
    final uri = Uri.parse('tel:+226${artisan.telephone}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    final message = Uri.encodeComponent(
        'Bonjour ${artisan.displayName}, j\'ai trouvé votre profil sur Tondo. Êtes-vous disponible ?');
    final uri =
        Uri.parse('https://wa.me/226${artisan.telephone}?text=$message');
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // HEADER ROUGE
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.red,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.red,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Text(artisan.metierEmoji,
                            style: const TextStyle(fontSize: 40)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(artisan.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        )),
                    Text(artisan.metierLabel,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        )),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // STATS
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat('⭐', '${artisan.notemoyenne}', 'Note'),
                        _divider(),
                        _stat('💬', '${artisan.totalAvis}', 'Avis'),
                        _divider(),
                        _stat('✅', '${artisan.totalMissions}', 'Missions'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // BADGE VÉRIFIÉ
                  if (artisan.isVerified)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.verified,
                              color: AppColors.green, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Artisan Vérifié Tondo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.green,
                                      fontSize: 14,
                                    )),
                                Text('Identité et compétences contrôlées',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.green,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),

                  // INFOS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Informations',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.black,
                            )),
                        const SizedBox(height: 12),
                        _info(Icons.location_on_outlined,
                            artisan.quartierPrincipal),
                        _info(
                            Icons.circle,
                            artisan.statut == 'disponible'
                                ? 'Disponible maintenant'
                                : 'Non disponible',
                            color: artisan.statut == 'disponible'
                                ? AppColors.green
                                : AppColors.mid),
                        _info(Icons.payment_outlined,
                            'Orange Money · Moov Money'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bouton noter
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FirebaseAuth.instance.currentUser?.isAnonymous ==
                              true
                          ? OutlinedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              ),
                              icon: const Icon(Icons.star_outline, size: 18),
                              label: const Text('Se connecter pour noter'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.red,
                                side: const BorderSide(color: AppColors.red),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        NoterScreen(artisan: artisan)),
                              ),
                              icon: const Icon(Icons.star,
                                  size: 18, color: Colors.white),
                              label: const Text('Laisser un avis'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF59E0B),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                    ),
                  ),

                  // BOUTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _appeler,
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Appeler'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.black,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _whatsapp,
                          icon: const Icon(Icons.message,
                              size: 18, color: Colors.white),
                          label: const Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.black,
            )),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mid)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: AppColors.border);
  }

  Widget _info(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? AppColors.mid),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                fontSize: 13,
                color: color ?? AppColors.mid,
              )),
        ],
      ),
    );
  }
}
