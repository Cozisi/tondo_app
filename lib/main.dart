import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/constants/app_colors.dart';
import 'screens/home/home_screen.dart';
import 'screens/favoris/favoris_screen.dart';
import 'screens/missions/missions_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/user_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TondoApp());
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
}

class TondoApp extends StatelessWidget {
  const TondoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tondo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'DMSans',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.red),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    FavorisScreen(),
    MissionsScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.red.withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.red),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite, color: AppColors.red),
            label: 'Favoris',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: AppColors.red),
            label: 'Missions',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.red),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// PROFIL SCREEN
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _userService = UserService();
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerRole();
  }

  Future<void> _chargerRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final role = doc.data()?['role'];
    if (mounted)
      setState(() {
        _role = role;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.red),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: _role == null
            ? _ecranNonConnecte(context)
            : _role == 'artisan'
                ? _tableauBordArtisan(context)
                : _ecranClient(context),
      ),
    );
  }

  Widget _ecranNonConnecte(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text('Mon Profil',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              )),
          const SizedBox(height: 8),
          const Text('Connectez-vous pour accéder à votre profil',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mid)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ).then((_) => _chargerRole()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99)),
              ),
              child: const Text('Se connecter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ecranClient(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👤', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text('Mon Compte',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              )),
          const SizedBox(height: 8),
          Text(user?.phoneNumber ?? 'Client Tondo',
              style: const TextStyle(color: AppColors.mid, fontSize: 16)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await FirebaseAuth.instance.signInAnonymously();
                setState(() {
                  _role = null;
                  _loading = false;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99)),
              ),
              child: const Text('Se déconnecter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableauBordArtisan(BuildContext context) {
    return FutureBuilder<DocumentSnapshot?>(
      future: _userService.getArtisanProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.red),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mon Tableau de Bord',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  )),
              const SizedBox(height: 20),
              if (data != null) ...[
                // PROFIL
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(data['metierEmoji'] ?? '🔧',
                              style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['displayName'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.black,
                                )),
                            Text(data['metierLabel'] ?? '',
                                style: const TextStyle(
                                  color: AppColors.mid,
                                  fontSize: 13,
                                )),
                          ],
                        ),
                      ),
                      if (data['isVerified'] == true)
                        const Icon(Icons.verified,
                            color: AppColors.green, size: 22),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // STATS
                Row(
                  children: [
                    Expanded(
                        child: _statCard(
                            '⭐', '${data['notemoyenne'] ?? 0}', 'Note')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _statCard(
                            '💬', '${data['totalAvis'] ?? 0}', 'Avis')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _statCard(
                            '✅', '${data['totalMissions'] ?? 0}', 'Missions')),
                  ],
                ),
                const SizedBox(height: 12),

                // DISPONIBILITÉ
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Disponibilité',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.black,
                              )),
                          Text(
                            data['statut'] == 'disponible'
                                ? 'Visible par les clients'
                                : 'Masqué des recherches',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mid,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: data['statut'] == 'disponible',
                        activeColor: AppColors.green,
                        onChanged: (val) async {
                          await FirebaseFirestore.instance
                              .collection('artisans')
                              .doc(snapshot.data!.id)
                              .update(
                                  {'statut': val ? 'disponible' : 'indispo'});
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.redLight,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.red.withValues(alpha: 0.2)),
                  ),
                  child: const Column(
                    children: [
                      Text('⚠️', style: TextStyle(fontSize: 32)),
                      SizedBox(height: 8),
                      Text('Profil artisan non trouvé',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.red,
                          )),
                      SizedBox(height: 4),
                      Text(
                        'Contactez Tondo pour lier votre profil.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    await FirebaseAuth.instance.signInAnonymously();
                    setState(() {
                      _role = null;
                      _loading = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99)),
                  ),
                  child: const Text('Se déconnecter',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.black,
              )),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.mid)),
        ],
      ),
    );
  }
}
