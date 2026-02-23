import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_colors.dart';
import 'screens/home/home_screen.dart';
import 'screens/favoris/favoris_screen.dart';
import 'screens/missions/missions_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/artisan/dashboard_artisan_screen.dart';
import 'services/user_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }
  runApp(const TondoApp());
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
      if (mounted)
        setState(() {
          _role = 'client';
          _loading = false;
        });
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final role = doc.data()?['role'];
    if (mounted)
      setState(() {
        _role = role ?? 'client';
        _loading = false;
      });
  }

  Future<void> _deconnecter() async {
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signInAnonymously();
    if (mounted)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (_) => false,
      );
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
        child: _role == 'artisan'
            ? _tableauBordArtisan(context)
            : _ecranClient(context),
      ),
    );
  }

  Widget _ecranClient(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final estConnecte = user != null && !user.isAnonymous;

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final prenom = data?['prenom'] ?? '';
        final nom = data?['nom'] ?? '';
        final telephone = data?['telephone'] ?? '';

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                estConnecte && prenom.isNotEmpty
                    ? '$prenom $nom'
                    : 'Mon Compte',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                estConnecte
                    ? telephone.isNotEmpty
                        ? telephone
                        : 'Client Tondo'
                    : 'Connectez-vous pour accéder à votre profil',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.mid, fontSize: 15),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: estConnecte
                    ? OutlinedButton(
                        onPressed: _deconnecter,
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
                      )
                    : ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
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
      },
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

        if (data == null) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  const Text('Profil artisan non trouvé',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.red,
                      )),
                  const SizedBox(height: 4),
                  const Text('Contactez Tondo pour lier votre profil.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.red)),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _deconnecter,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99)),
                    ),
                    child: const Text('Se déconnecter'),
                  ),
                ],
              ),
            ),
          );
        }

        return DashboardArtisanScreen(
          artisanId: snapshot.data!.id,
          data: data,
          onDeconnecter: _deconnecter,
        );
      },
    );
  }
}
