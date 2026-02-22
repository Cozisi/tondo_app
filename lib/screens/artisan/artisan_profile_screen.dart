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
          // HEADER AVEC BANNIÈRE
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.red,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // BANNIÈRE
                  Positioned.fill(
                    child: artisan.banniereUrl.isNotEmpty
                        ? Image.network(
                            artisan.banniereUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.red,
                            ),
                          )
                        : Container(color: AppColors.red),
                  ),

                  // GRADIENT SOMBRE
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // INFOS EN BAS
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        // PHOTO DE PROFIL + EMOJI
                        Stack(
                          children: [
                            // Photo de profil
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: artisan.photoUrl.isNotEmpty
                                    ? Image.network(
                                        artisan.photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                          child: Center(
                                            child: Text(artisan.metierEmoji,
                                                style: const TextStyle(
                                                    fontSize: 30)),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        child: Center(
                                          child: Text(artisan.metierEmoji,
                                              style: const TextStyle(
                                                  fontSize: 30)),
                                        ),
                                      ),
                              ),
                            ),

                            // EMOJI MÉTIER en badge
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                ),
                                child: Center(
                                  child: Text(artisan.metierEmoji,
                                      style: const TextStyle(fontSize: 12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // NOM + MÉTIER
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(artisan.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  )),
                              Text(artisan.metierLabel,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13,
                                  )),
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.star_rounded,
                                    color: Color(0xFFF59E0B), size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  '${artisan.notemoyenne} · ${artisan.totalAvis} avis',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  const SizedBox(height: 12),

                  // PORTFOLIO
                  if (artisan.photos.isNotEmpty) ...[
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
                          const Text('Réalisations',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.black,
                              )),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: artisan.photos.length,
                            itemBuilder: (_, i) {
                              return GestureDetector(
                                onTap: () => _voirPhoto(context, i),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    artisan.photos[i],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (_, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        color: AppColors.gray,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.red,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.gray,
                                      child: const Icon(Icons.broken_image,
                                          color: AppColors.mid),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // BOUTON NOTER
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

                  // BOUTONS CONTACT
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
                          icon: const Icon(Icons.chat,
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _voirPhoto(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoViewer(
          photos: artisan.photos,
          initialIndex: index,
        ),
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

class _PhotoViewer extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const _PhotoViewer({required this.photos, required this.initialIndex});

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${_current + 1} / ${widget.photos.length}',
            style: const TextStyle(color: Colors.white)),
      ),
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (i) => setState(() => _current = i),
        itemCount: widget.photos.length,
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.network(
              widget.photos[i],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                color: Colors.white54,
                size: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
