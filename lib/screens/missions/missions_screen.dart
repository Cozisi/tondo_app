import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final estConnecte = user != null && !user.isAnonymous;

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
              child: const Text('Mes Missions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  )),
            ),

            if (!estConnecte)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        const Text('Connectez-vous pour voir vos missions',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            )),
                        const SizedBox(height: 8),
                        const Text(
                          'Suivez vos demandes et l\'avancement de vos travaux',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.mid),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (estConnecte)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('missions')
                      .where('clientId', isEqualTo: user.uid)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.red),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('📋', style: TextStyle(fontSize: 60)),
                              SizedBox(height: 16),
                              Text('Aucune mission pour l\'instant',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  )),
                              SizedBox(height: 8),
                              Text(
                                'Contactez un artisan pour démarrer une mission',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.mid),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final missions = snapshot.data!.docs;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: missions.length,
                      itemBuilder: (_, i) {
                        final m = missions[i].data() as Map<String, dynamic>;
                        return _MissionCard(mission: m);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final Map<String, dynamic> mission;
  const _MissionCard({required this.mission});

  Color _statutColor(String statut) {
    switch (statut) {
      case 'en_cours':
        return AppColors.green;
      case 'terminé':
        return AppColors.green;
      case 'annulé':
        return AppColors.red;
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _statutLabel(String statut) {
    switch (statut) {
      case 'en_attente':
        return '⏳ En attente';
      case 'en_cours':
        return '🔧 En cours';
      case 'terminé':
        return '✅ Terminé';
      case 'annulé':
        return '❌ Annulé';
      default:
        return statut;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statut = mission['statut'] ?? 'en_attente';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mission['artisanNom'] ?? 'Artisan',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.black,
                  )),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statutColor(statut).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(_statutLabel(statut),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statutColor(statut),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(mission['metier'] ?? '',
              style: const TextStyle(color: AppColors.mid, fontSize: 13)),
          if (mission['description'] != null &&
              mission['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(mission['description'],
                style: const TextStyle(fontSize: 13, color: AppColors.black)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.mid),
              const SizedBox(width: 4),
              Text(mission['quartier'] ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.mid)),
              const Spacer(),
              const Icon(Icons.access_time, size: 14, color: AppColors.mid),
              const SizedBox(width: 4),
              Text(
                mission['createdAt'] != null
                    ? _formatDate((mission['createdAt'] as Timestamp).toDate())
                    : '',
                style: const TextStyle(fontSize: 12, color: AppColors.mid),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Hier';
    return '${date.day}/${date.month}/${date.year}';
  }
}
