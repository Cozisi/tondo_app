import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../models/artisan_model.dart';
import '../screens/artisan/artisan_profile_screen.dart';

class ArtisanCard extends StatelessWidget {
  final ArtisanModel artisan;

  const ArtisanCard({super.key, required this.artisan});

  Future<void> _faireAppel() async {
    final Uri launchUri = Uri(scheme: 'tel', path: artisan.telephone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _lancerWhatsApp() async {
    String numero = artisan.telephone.replaceAll(RegExp(r'\D'), '');
    if (!numero.startsWith('226')) numero = '226$numero';
    final String message = Uri.encodeComponent(
        'Bonjour ${artisan.displayName}, je vous contacte via Tondo. Êtes-vous disponible ?');
    final Uri url = Uri.parse('https://wa.me/$numero?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArtisanProfileScreen(artisan: artisan),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar emoji
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(artisan.metierEmoji,
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 12),

                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(artisan.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.black,
                          )),
                      const SizedBox(height: 2),
                      Text(
                          '${artisan.metierLabel} · ${artisan.quartierPrincipal}',
                          style: const TextStyle(
                            color: AppColors.mid,
                            fontSize: 12,
                          )),
                      const SizedBox(height: 6),
                      if (artisan.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.greenLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('✓ Vérifié Tondo',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.green,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                    ],
                  ),
                ),

                // Note
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFF59E0B), size: 16),
                      const SizedBox(width: 2),
                      Text(artisan.notemoyenne.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          )),
                    ]),
                    Text('${artisan.totalAvis} avis',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mid,
                        )),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _faireAppel,
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Appeler'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.black,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _lancerWhatsApp,
                    icon: const Icon(Icons.chat, size: 16, color: Colors.white),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(
                        fontSize: 13,
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
    );
  }
}
