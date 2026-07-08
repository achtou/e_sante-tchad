import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/user_model.dart';
import 'models/dossier_model.dart';
import 'models/medicament_model.dart';
import 'models/sante_maternelle_model.dart';
import 'models/prevention_model.dart';
import 'models/maladie_chronique_model.dart';
import 'pages/maladies_chroniques_page.dart';
import 'services/language_service.dart';
import 'services/medicament_notification_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'pages/dossier_medical_page.dart';
import 'pages/ia_symptomes_page.dart';
import 'pages/rappel_medicaments_page.dart';
import 'pages/carte_structures_page.dart';
import 'pages/sante_maternelle_page.dart';
import 'pages/prevention_conseils_page.dart';
import 'pages/medicament_module/add_meds_page.dart';
import 'pages/medicament_module/family_profiles_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Initialiser le service de langue
  await LanguageService.init();
  
  // Initialiser le service de notifications
  final notificationService = MedicamentNotificationService();
  await notificationService.initialize();
  await notificationService.requestNotificationPermission();
  
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(DossierMedicalAdapter());
  Hive.registerAdapter(MedicamentAdapter());
  Hive.registerAdapter(PriseMedicamentAdapter());
  Hive.registerAdapter(GrossesseAdapter());
  Hive.registerAdapter(VisitePrenataleAdapter());
  Hive.registerAdapter(EnfantAdapter());
  Hive.registerAdapter(VaccinationAdapter());
  Hive.registerAdapter(SuiviCroissanceAdapter());
  Hive.registerAdapter(ConseilSanteAdapter());
  Hive.registerAdapter(MaladieChroniqueAdapter());
  Hive.registerAdapter(MesureVitaleAdapter());
  Hive.registerAdapter(ProfilFamilleAdapter());
  
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<DossierMedical>('dossiers');
  await Hive.openBox<Medicament>('medicaments');
  await Hive.openBox<PriseMedicament>('prises');
  await Hive.openBox<Grossesse>('grossesses');
  await Hive.openBox<VisitePrenatale>('visites_prenatales');
  await Hive.openBox<Enfant>('enfants');
  await Hive.openBox<Vaccination>('vaccinations');
  await Hive.openBox<SuiviCroissance>('suivi_croissance');
  await Hive.openBox<ConseilSante>('conseils_sante');
  await Hive.openBox<MaladieChronique>('maladies_chroniques');
  await Hive.openBox<ProfilFamille>('profils_famille');
  
  // Créer un profil "Moi" par défaut si la box est vide
  final profilsBox = Hive.box<ProfilFamille>('profils_famille');
  if (profilsBox.isEmpty) {
    final profilDefaut = ProfilFamille(
      id: 'moi',
      nom: 'Moi',
      relation: 'Moi',
      dateNaissance: DateTime(1995, 1, 1),
    );
    await profilsBox.put('moi', profilDefaut);
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Santé Tchad',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A86B),
          brightness: Brightness.light,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const SplashScreen(),
    );
  }
}


class SanteTchadApp extends StatelessWidget {
  const SanteTchadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Santé-Tchad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A86B),
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardPage(),
        '/dossier-medical': (context) => const DossierMedicalPage(),
        '/ia-symptomes': (context) => const IaSymptomesPage(),
        '/rappel-medicaments': (context) => const RappelMedicamentsPage(),
        '/carte-structures': (context) => const CarteStructuresPage(),
        '/sante-maternelle': (context) => const SanteMaternellePage(),
        '/maladies-chroniques': (context) => const MaladiesChroniquesPage(),
        '/prevention-conseils': (context) => const PreventionConseilsPage(),
        // Routes module médicaments (appelées avec arguments via Navigator.push)
        '/medicaments/add': (context) => const AddMedsPage(),
        '/medicaments/family': (context) => const FamilyProfilesPage(),
      },
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _cardAnimations = List.generate(7, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutBack),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildGrid(context),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: 16),
              Text(
                'Santé-Tchad',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.28),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.45)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Mode hors-ligne',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final cards = [
      _CardData(
        title: 'Dossier Médical Personnel',
        description: 'Gérez vos documents médicaux',
        icon: Icons.folder_shared,
        color: const Color(0xFF4CAF50),
        route: '/dossier-medical',
      ),
      _CardData(
        title: 'Assistant IA de Symptômes',
        description: 'Analyse intelligente de symptômes',
        icon: Icons.psychology,
        color: const Color(0xFF2196F3),
        route: '/ia-symptomes',
      ),
      _CardData(
        title: 'Rappel de Médicaments',
        description: 'Ne ratez aucun traitement',
        icon: Icons.alarm,
        color: const Color(0xFFFF9800),
        route: '/rappel-medicaments',
      ),
      _CardData(
        title: 'Carte des Structures',
        description: 'Trouvez les services de santé',
        icon: Icons.map,
        color: const Color(0xFF9C27B0),
        route: '/carte-structures',
      ),
      _CardData(
        title: 'Suivi Maternel',
        description: 'Accompagnement grossesse',
        icon: Icons.pregnant_woman,
        color: const Color(0xFFE91E63),
        route: '/sante-maternelle',
      ),
      _CardData(
        title: 'Maladies Chroniques',
        description: 'Suivi personnalisé',
        icon: Icons.favorite,
        color: const Color(0xFFF44336),
        route: '/maladies-chroniques',
      ),
      _CardData(
        title: 'Prévention & Conseils',
        description: 'Conseils santé quotidiens',
        icon: Icons.lightbulb,
        color: const Color(0xFF00BCD4),
        route: '/prevention-conseils',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 28,
          mainAxisSpacing: 28,
          childAspectRatio: 1.8,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _cardAnimations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 60 * (1 - _cardAnimations[index].value)),
                child: Opacity(
                  opacity: _cardAnimations[index].value,
                  child: _buildCard(context, cards[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, _CardData data) {
    bool isPressed = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: () => Navigator.pushNamed(context, data.route),
          child: AnimatedScale(
            scale: isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: data.color.withOpacity(0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: data.color.withOpacity(0.1),
                  width: 1.8,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => Navigator.pushNamed(context, data.route),
                  splashColor: data.color.withOpacity(0.15),
                  highlightColor: data.color.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(26),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'icon-${data.route}',
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [data.color, data.color.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: data.color.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              data.icon,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(-6 * (1 - value), 0),
                              child: Opacity(
                                opacity: value,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                  color: data.color,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite,
            color: Color(0xFFE91E63),
            size: 22,
          ),
          const SizedBox(width: 12),
          Text(
            'Réalisé avec passion par Achta Sougoudou',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  _CardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
