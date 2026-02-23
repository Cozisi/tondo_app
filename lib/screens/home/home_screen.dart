import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/artisan_service.dart';
import '../../widgets/artisan_card.dart';
import '../../models/artisan_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = ArtisanService();
  final _searchController = TextEditingController();
  String? _categorieSelectionnee;
  String _recherche = '';

  static const _categories = [
    {'emoji': '🚰', 'label': 'Plombier', 'metier': 'plombier'},
    {'emoji': '⚡', 'label': 'Électricien', 'metier': 'electricien'},
    {'emoji': '🔨', 'label': 'Menuisier', 'metier': 'menuisier'},
    {'emoji': '🏠', 'label': 'Maçon', 'metier': 'macon'},
    {'emoji': '🎨', 'label': 'Peintre', 'metier': 'peintre'},
    {'emoji': '❄️', 'label': 'Clim', 'metier': 'climatisation'},
    {'emoji': '🔧', 'label': 'Mécanicien', 'metier': 'mecanicien'},
    {'emoji': '➕', 'label': 'Autre', 'metier': 'autre'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ArtisanModel> _filtrer(List<ArtisanModel> artisans) {
    if (_recherche.isEmpty) return artisans;
    final q = _recherche.toLowerCase();
    return artisans
        .where((a) =>
            a.displayName.toLowerCase().contains(q) ||
            a.quartierPrincipal.toLowerCase().contains(q) ||
            a.metierLabel.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // HEADER
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tondo',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.red,
                            )),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.greenLight,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text('Ouagadougou',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.green,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Bonjour 👋 Quel service ?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        )),
                  ],
                ),
              ),
            ),

            // BARRE DE RECHERCHE
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _recherche = v),
                  decoration: InputDecoration(
                    hintText: 'Chercher un artisan ou un quartier...',
                    hintStyle: TextStyle(color: AppColors.mid, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppColors.mid),
                    suffixIcon: _recherche.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.mid),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _recherche = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // CATÉGORIES
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  itemCount: _categories.length,
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    final selected = _categorieSelectionnee == cat['metier'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _categorieSelectionnee =
                              selected ? null : cat['metier'];
                        });
                      },
                      child: Container(
                        width: 72,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.red : AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? AppColors.red : AppColors.border,
                            width: selected ? 2 : 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.red.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat['emoji']!,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 4),
                            Text(cat['label']!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppColors.white
                                      : AppColors.black,
                                ),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // TITRE SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _recherche.isNotEmpty
                          ? 'RÉSULTATS DE RECHERCHE'
                          : _categorieSelectionnee == null
                              ? 'ARTISANS DISPONIBLES'
                              : '${_categories.firstWhere((c) => c['metier'] == _categorieSelectionnee)['label']!.toUpperCase()}S',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppColors.mid,
                      ),
                    ),
                    if (_categorieSelectionnee != null && _recherche.isEmpty)
                      GestureDetector(
                        onTap: () =>
                            setState(() => _categorieSelectionnee = null),
                        child: const Text('Tout voir',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.red,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                  ],
                ),
              ),
            ),

            // LISTE ARTISANS
            StreamBuilder<List<ArtisanModel>>(
              stream: _categorieSelectionnee == null
                  ? _service.getArtisansDisponibles()
                  : _service.getArtisansByMetier(_categorieSelectionnee!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: AppColors.red),
                      ),
                    ),
                  );
                }

                final tous = snapshot.data ?? [];
                final artisans = _filtrer(tous);

                if (artisans.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Text('😔', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 12),
                            Text(
                              _recherche.isNotEmpty
                                  ? 'Aucun résultat pour "$_recherche"'
                                  : 'Aucun artisan disponible',
                              style: const TextStyle(color: AppColors.mid),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => ArtisanCard(artisan: artisans[i]),
                      childCount: artisans.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }
}
