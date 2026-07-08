import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';  // Temporairement désactivé pour build APK
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../services/language_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  String _userName = '';
  bool _isArabic = false;
  bool _isOnline = true;
  int _selectedIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  // late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;  // Temporairement désactivé pour build APK
  final TextEditingController _searchController = TextEditingController();

  final List<_ServiceCard> _serviceCards = [
    _ServiceCard(
      icon: Icons.person,
      color: AppColors.primary,
      titleFR: 'Mon Dossier',
      titleAR: 'ملفي الطبي',
      subtitleFR: 'Infos médicales',
      subtitleAR: 'معلوماتي',
      route: '/dossier-medical',
    ),
    _ServiceCard(
      icon: Icons.psychology,
      color: const Color(0xFF27ae60),
      titleFR: 'Assistant IA',
      titleAR: 'مساعد ذكي',
      subtitleFR: 'Analyser symptômes',
      subtitleAR: 'تحليل الأعراض',
      route: '/ia-symptomes',
      hasBadge: true,
      badgeText: 'IA',
    ),
    _ServiceCard(
      icon: Icons.medication,
      color: const Color(0xFFe67e22),
      titleFR: 'Médicaments',
      titleAR: 'الأدوية',
      subtitleFR: 'Rappels & suivi',
      subtitleAR: 'تذكير ومتابعة',
      route: '/rappel-medicaments',
    ),
    _ServiceCard(
      icon: Icons.local_hospital,
      color: const Color(0xFF8e44ad),
      titleFR: 'Centres Santé',
      titleAR: 'مراكز الصحة',
      subtitleFR: 'Trouver un centre',
      subtitleAR: 'ابحث عن مركز',
      route: '/carte-structures',
    ),
    _ServiceCard(
      icon: Icons.pregnant_woman,
      color: const Color(0xFFe91e8c),
      titleFR: 'Suivi Grossesse',
      titleAR: 'متابعة الحمل',
      subtitleFR: 'Maman & Bébé',
      subtitleAR: 'الأم والطفل',
      route: '/sante-maternelle',
    ),
    _ServiceCard(
      icon: Icons.health_and_safety,
      color: const Color(0xFF00bcd4),
      titleFR: 'Prévention',
      titleAR: 'الوقاية',
      subtitleFR: 'Conseils santé',
      subtitleAR: 'نصائح صحية',
      route: '/maladies-chroniques',
    ),
  ];

  final List<_TipCard> _tipCards = [
    _TipCard(
      emoji: '💧',
      titleFR: 'Eau potable',
      titleAR: 'ماء الشرب',
      textFR: 'Faites bouillir l\'eau du robinet avant de boire',
      textAR: 'اغلِ ماء الصنبور قبل الشرب',
    ),
    _TipCard(
      emoji: '🦟',
      titleFR: 'Paludisme',
      titleAR: 'الملاريا',
      textFR: 'Dormez sous moustiquaire chaque nuit',
      textAR: 'نَم تحت ناموسية كل ليلة',
    ),
    _TipCard(
      emoji: '🧼',
      titleFR: 'Hygiène',
      titleAR: 'النظافة',
      textFR: 'Lavez-vous les mains après les toilettes',
      textAR: 'اغسل يديك بعد استخدام المرحاض',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // _checkConnectivity();  // Temporairement désactivé pour build APK
    _initAnimations();
    // _connectivitySubscription = Connectivity()  // Temporairement désactivé pour build APK
    //     .onConnectivityChanged
    //     .listen((List<ConnectivityResult> results) {
    //   setState(() {
    //     _isOnline = results.isNotEmpty && results.first != ConnectivityResult.none;
    //   });
    // });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    // _connectivitySubscription.cancel();  // Temporairement désactivé pour build APK
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? '';
      _isArabic = LanguageService.isArabic;
    });
  }

  void _performSearch(String query) {
    // Déterminer le type de recherche basé sur les mots-clés
    final lowerQuery = query.toLowerCase();
    
    // Mots-clés pour symptômes
    final symptomKeywords = ['symptôme', 'symptome', 'mal', 'douleur', 'fièvre', 'fievre', 'tête', 'ventre', 'maladie', 'diagnostic', 'analyse', 'ألم', 'مرض', 'حمى', 'صداع'];
    
    // Mots-clés pour médicaments
    final medKeywords = ['médicament', 'medicament', 'pilule', 'comprimé', 'comprime', 'traitement', 'remède', 'remede', 'rappel', 'prise', 'دواء', 'حبة', 'علاج'];
    
    // Mots-clés pour prévention/alerte saison
    final preventionKeywords = ['prévention', 'prevention', 'conseil', 'saison', 'alerte', 'hygiène', 'hygiene', 'nutrition', 'santé', 'sante', 'وقاية', 'نصيحة', 'موسم', 'تنبيه', 'نظافة', 'تغذية', 'صحة'];
    
    bool isSymptomSearch = symptomKeywords.any((keyword) => lowerQuery.contains(keyword));
    bool isMedSearch = medKeywords.any((keyword) => lowerQuery.contains(keyword));
    bool isPreventionSearch = preventionKeywords.any((keyword) => lowerQuery.contains(keyword));
    
    if (isSymptomSearch) {
      Navigator.pushNamed(context, '/ia-symptomes');
    } else if (isMedSearch) {
      Navigator.pushNamed(context, '/rappel-medicaments');
    } else if (isPreventionSearch) {
      Navigator.pushNamed(context, '/prevention-conseils');
    } else {
      // Par défaut, rediriger vers l'assistant IA pour les symptômes
      Navigator.pushNamed(context, '/ia-symptomes');
    }
  }

  // Future<void> _checkConnectivity() async {  // Temporairement désactivé pour build APK
  //   final connectivityResults = await Connectivity().checkConnectivity();
  //   setState(() {
  //     _isOnline = connectivityResults.isNotEmpty && connectivityResults.first != ConnectivityResult.none;
  //   });
  // }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  Future<void> _callEmergency() async {
    final url = 'tel:1313';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: Directionality(
          textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 14),
                      _buildServicesSection(),
                      const SizedBox(height: 14),
                      _buildAlertSection(),
                      const SizedBox(height: 14),
                      _buildTipsSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0d3b6e), Color(0xFF1a6fa8)],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 26,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF002664),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomLeft: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFECC00),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFC60C30),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isArabic ? '🇹🇩 تشاد' : '🇹🇩 Tchad',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isArabic ? 'مرحباً،' : 'Bienvenue,',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _userName.isEmpty 
                            ? (_isArabic ? 'ضيف' : 'Invité')
                            : _userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: AppColors.white, size: 22),
                          onPressed: () {},
                          padding: const EdgeInsets.all(8),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _userName.isEmpty 
                              ? '?'
                              : _userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF1a6fa8),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: _isArabic 
                            ? 'ابحث عن أعراض، أدوية...'
                            : 'Rechercher symptômes, médicaments...',
                        hintStyle: TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (query) {
                        if (query.trim().isEmpty) return;
                        _performSearch(query);
                        _searchController.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isOnline ? AppColors.primary : AppColors.danger,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _isOnline 
                            ? (_isArabic ? 'متصل' : 'En ligne')
                            : (_isArabic ? 'غير متصل' : 'Hors ligne'),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 400) return 2;
    if (width < 700) return 3;
    if (width < 1000) return 4;
    return 3;
  }

  double _getAspectRatio(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 400) return 1.0;
    if (width < 700) return 0.9;
    return 0.85;
  }

  Widget _buildServicesSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isArabic ? 'خدماتي' : 'Mes Services',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0d3b6e),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_serviceCards.length} services',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _isArabic ? 'ماذا تريد أن تفعل؟' : 'Que voulez-vous faire ?',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: _getCrossAxisCount(context),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: _getAspectRatio(context),
              children: _serviceCards.asMap().entries.map((entry) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (entry.key * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value,
                        child: _buildServiceCard(entry.value),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(_ServiceCard card) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, card.route),
      borderRadius: BorderRadius.circular(16),
      splashColor: card.color.withOpacity(0.15),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.white,
              card.color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                if (card.hasBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.danger.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      card.badgeText!,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: card.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: card.color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                card.icon,
                color: card.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isArabic ? card.titleAR : card.titleFR,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _isArabic ? card.subtitleAR : card.subtitleFR,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFf39c12), Color(0xFFe67e22)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFe67e22).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isArabic 
                        ? '⚠️ تنبيه موسم الملاريا'
                        : '⚠️ Alerte Saison Paludisme',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isArabic 
                        ? 'استخدم ناموسيات مشبعة بالمبيدات'
                        : 'Utilisez des moustiquaires imprégnées',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white.withOpacity(0.95),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _isArabic ? 'اعرف أكثر' : 'En savoir plus',
                style: const TextStyle(
                  color: Color(0xFFe67e22),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isArabic ? 'نصائح اليوم' : 'Conseils du jour',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0d3b6e),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_tipCards.length} conseils',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tipCards.length,
                itemBuilder: (context, index) {
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 150)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(50 * (1 - value), 0),
                        child: Opacity(
                          opacity: value,
                          child: _buildTipCard(_tipCards[index]),
                        ),
                      );
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

  Widget _buildTipCard(_TipCard tip) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white,
            AppColors.primary.withOpacity(0.03),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tip.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isArabic ? tip.titleAR : tip.titleFR,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isArabic ? tip.textAR : tip.textFR,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 0, _isArabic ? 'الرئيسية' : 'Accueil'),
              _buildNavItem(Icons.person, 1, _isArabic ? 'ملفي' : 'Profil'),
              _buildNavItem(Icons.psychology, 2, _isArabic ? 'مساعد' : 'IA'),
              _buildNavItem(Icons.medication, 3, _isArabic ? 'أدوية' : 'Médic'),
              _buildNavItem(Icons.menu, 4, _isArabic ? 'قائمة' : 'Menu'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final isActive = index == _selectedIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 4) {
          _showDrawer();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textMedium,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.primary : AppColors.textMedium,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              _buildDrawerItem(Icons.settings, _isArabic ? 'الإعدادات' : 'Paramètres'),
              _buildDrawerItem(Icons.logout, _isArabic ? 'تسجيل الخروج' : 'Déconnexion'),
              _buildDrawerItem(Icons.info_outline, _isArabic ? 'حول' : 'À propos'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _ServiceCard {
  final IconData icon;
  final Color color;
  final String titleFR;
  final String titleAR;
  final String subtitleFR;
  final String subtitleAR;
  final String route;
  final bool hasBadge;
  final String? badgeText;

  _ServiceCard({
    required this.icon,
    required this.color,
    required this.titleFR,
    required this.titleAR,
    required this.subtitleFR,
    required this.subtitleAR,
    required this.route,
    this.hasBadge = false,
    this.badgeText,
  });
}

class _TipCard {
  final String emoji;
  final String titleFR;
  final String titleAR;
  final String textFR;
  final String textAR;

  _TipCard({
    required this.emoji,
    required this.titleFR,
    required this.titleAR,
    required this.textFR,
    required this.textAR,
  });
}
