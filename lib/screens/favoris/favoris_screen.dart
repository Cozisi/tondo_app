import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../models/artisan_model.dart';
import '../../services/favoris_service.dart';
import '../../widgets/artisan_card.dart';

class FavorisScreen extends StatefulWidget {
  const FavorisScreen({super.key});

  @override
  State<FavorisScreen> createState() => _FavorisScreenState();
}

class _FavorisScreenState extends State<FavorisScreen> {
  final _service = FavorisService();
  List<ArtisanModel> _favoris = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerFavoris();
  }

  Future<void> _chargerFavoris() async {
    setState(() => _loading = true);
    final ids = await _service.getFavoris();
    if (ids.isEmpty) {
      setState(() {
        _favoris = [];
        _loading = false;
      });
      return;
    }
    final snap = await FirebaseFirestore.instance
        .collection('artisans')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    setState(() {
      _favoris =
          snap.docs.map((doc) => ArtisanModel.fromFirestore(doc)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              color: AppColors.white,
              child: const Text('Mes Favoris',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  )),
            ),

            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.red),
                ),
              )
            else if (_favoris.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('❤️', style: TextStyle(fontSize: 60)),
                        SizedBox(height: 16),
                        Text('Aucun favori pour l\'instant',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            )),
                        SizedBox(height: 8),
                        Text(
                          'Appuyez sur ❤️ sur une carte artisan pour l\'ajouter à vos favoris',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.mid),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _chargerFavoris,
                  color: AppColors.red,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favoris.length,
                    itemBuilder: (_, i) => ArtisanCard(artisan: _favoris[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
