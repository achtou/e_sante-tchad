import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/user_model.dart';
import 'models/dossier_model.dart';
import 'models/medicament_model.dart';
import 'models/sante_maternelle_model.dart';
import 'models/prevention_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'pages/dossier_medical_page.dart';
import 'pages/ia_symptomes_page.dart';
import 'pages/rappel_medicaments_page.dart';
import 'pages/carte_structures_page.dart';
import 'pages/sante_maternelle_page.dart';
import 'pages/maladies_chroniques_page.dart';
import 'pages/prevention_conseils_page.dart';
import 'pages/medicament_module/add_meds_page.dart';
import 'pages/medicament_module/family_profiles_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
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
  
  runApp(const SanteTchadApp());
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

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Santé-Tchad',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.offline_bolt,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mode local hors-ligne activé',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
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
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.7,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return _buildCard(context, cards[index]);
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, _CardData data) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, data.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()..translate(0.0, 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pushNamed(context, data.route),
              splashColor: data.color.withOpacity(0.1),
              highlightColor: data.color.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: data.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        data.icon,
                        color: data.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user,
            color: const Color(0xFF00A86B),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Réalisé par Achta Sougoudou',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Color(0xFF475569),
              letterSpacing: 0.5,
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
