import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/prevention_model.dart';
import '../utils/colors.dart';

class PreventionConseilsPage extends StatefulWidget {
  const PreventionConseilsPage({super.key});

  @override
  State<PreventionConseilsPage> createState() => _PreventionConseilsPageState();
}

class _PreventionConseilsPageState extends State<PreventionConseilsPage> {
  final _uuid = const Uuid();
  late Box<ConseilSante> _conseilsBox;
  String _selectedCategory = 'Tous';
  final _searchController = TextEditingController();

  final List<CategoriePrevention> _categories = [
    CategoriePrevention(
      id: 'nutrition',
      nom: 'Nutrition',
      description: 'Conseils alimentaires sains',
      icon: 'restaurant',
      color: '#FF9800',
    ),
    CategoriePrevention(
      id: 'hygiene',
      nom: 'Hygiène',
      description: 'Pratiques d\'hygiène',
      icon: 'clean_hands',
      color: '#2196F3',
    ),
    CategoriePrevention(
      id: 'maladies',
      nom: 'Maladies',
      description: 'Prévention des maladies',
      icon: 'medical_services',
      color: '#F44336',
    ),
    CategoriePrevention(
      id: 'exercice',
      nom: 'Exercice',
      description: 'Activité physique',
      icon: 'fitness_center',
      color: '#4CAF50',
    ),
    CategoriePrevention(
      id: 'sante_mentale',
      nom: 'Santé Mentale',
      description: 'Bien-être psychologique',
      icon: 'psychology',
      color: '#9C27B0',
    ),
    CategoriePrevention(
      id: 'environnement',
      nom: 'Environnement',
      description: 'Santé environnementale',
      icon: 'eco',
      color: '#009688',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _conseilsBox = Hive.box<ConseilSante>('conseils_sante');
    _initializeConseils().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _initializeConseils() async {
    final conseilsExistants = _conseilsBox.values.toList();
    
    final conseils = [
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Boire suffisamment d\'eau',
        categorie: 'nutrition',
        description: 'L\'hydratation est essentielle pour le bon fonctionnement de votre corps. Buvez au moins 8 verres d\'eau par jour.',
        pointsCles: [
          'Buvez de l\'eau avant chaque repas',
          'Privilégiez l\'eau du robinet traitée',
          'Évitez les boissons sucrées',
          'Augmentez votre consommation en cas de chaleur',
        ],
        imageIcon: 'water_drop',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 1,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Lavage des mains',
        categorie: 'hygiene',
        description: 'Le lavage régulier des mains est la mesure la plus efficace pour prévenir la propagation des infections.',
        pointsCles: [
          'Lavez-vous les mains avant de manger',
          'Utilisez du savon et de l\'eau propre',
          'Frottez pendant au moins 20 secondes',
          'Séchez-vous les mains avec un propre tissu',
        ],
        imageIcon: 'wash',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 2,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Prévention du paludisme',
        categorie: 'maladies',
        description: 'Le paludisme est une maladie grave mais préventable. Utilisez des moustiquaires et évitez les piqûres.',
        pointsCles: [
          'Dormez sous une moustiquaire imprégnée',
          'Utilisez des répulsifs anti-moustiques',
          'Éliminez les eaux stagnantes',
          'Consultez rapidement en cas de fièvre',
        ],
        imageIcon: 'pest_control',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 3,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Marche quotidienne',
        categorie: 'exercice',
        description: 'La marche est un excellent exercice accessible à tous. Essayez de marcher au moins 30 minutes par jour.',
        pointsCles: [
          'Commencez par 15 minutes par jour',
          'Augmentez progressivement la durée',
          'Marchez à un rythme modéré',
          'Profitez pour écouter de la musique',
        ],
        imageIcon: 'directions_walk',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 4,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Gestion du stress',
        categorie: 'sante_mentale',
        description: 'Le stress peut affecter votre santé physique et mentale. Apprenez à le gérer efficacement.',
        pointsCles: [
          'Pratiquez la respiration profonde',
          'Faites des pauses régulières',
          'Parlez à quelqu\'un de confiance',
          'Dormez suffisamment',
        ],
        imageIcon: 'self_improvement',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 5,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Qualité de l\'air',
        categorie: 'environnement',
        description: 'L\'air que vous respirez affecte votre santé. Assurez-vous d\'avoir un environnement sain.',
        pointsCles: [
          'Aérez votre logement quotidiennement',
          'Évitez de fumer à l\'intérieur',
          'Utilisez des plantes dépolluantes',
          'Évitez les zones de pollution intense',
        ],
        imageIcon: 'air',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 6,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Alimentation équilibrée',
        categorie: 'nutrition',
        description: 'Une alimentation variée et équilibrée est essentielle pour maintenir une bonne santé.',
        pointsCles: [
          'Mangez des fruits et légumes chaque jour',
          'Privilégiez les protéines maigres',
          'Limitez le sel et le sucre',
          'Choisissez des graisses saines',
        ],
        imageIcon: 'restaurant_menu',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 7,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Vaccination',
        categorie: 'maladies',
        description: 'La vaccination est le moyen le plus efficace de se protéger contre plusieurs maladies graves.',
        pointsCles: [
          'Suivez le calendrier vaccinal',
          'Gardez vos carnets de vaccination',
          'Vaccinez toute la famille',
          'Consultez votre centre de santé',
        ],
        imageIcon: 'vaccines',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 8,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Prévention du choléra',
        categorie: 'maladies',
        description: 'Le choléra est une infection intestinale grave causée par la consommation d\'eau ou d\'aliments contaminés.',
        pointsCles: [
          'Buvez uniquement de l\'eau traitée ou bouillie',
          'Lavez-vous les mains régulièrement avec du savon',
          'Cuisinez bien les aliments, surtout les poissons',
          'Évitez les aliments vendus dans la rue',
          'Utilisez des latrines propres et hygiéniques',
          'Désinfectez l\'eau avec du chlore si nécessaire',
        ],
        imageIcon: 'water_damage',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 9,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Prévention de la typhoïde',
        categorie: 'maladies',
        description: 'La fièvre typhoïde est une infection bactérienne causée par Salmonella Typhi, transmise par l\'eau et les aliments contaminés.',
        pointsCles: [
          'Buvez de l\'eau potable ou traitée',
          'Évitez les aliments crus ou mal cuits',
          'Lavez les fruits et légumes à l\'eau propre',
          'Se laver les mains après les toilettes',
          'Faites-vous vacciner si vous voyagez',
          'Évitez les glaçons dans les boissons',
        ],
        imageIcon: 'coronavirus',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 10,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Prévention des diarrhées',
        categorie: 'maladies',
        description: 'Les diarrhées sont souvent causées par des infections, une mauvaise hygiène ou une consommation d\'eau contaminée.',
        pointsCles: [
          'Utilisez uniquement de l\'eau traitée ou bouillie',
          'Lavez-vous les mains avant de manger',
          'Conservez les aliments au réfrigérateur',
          'Cuisinez bien les viandes et poissons',
          'Allaitement maternel exclusif pour les bébés (6 mois)',
          'Utilisez le SRO en cas de déshydratation',
        ],
        imageIcon: 'sick',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 11,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Prévention de la dengue',
        categorie: 'maladies',
        description: 'La dengue est une maladie virale transmise par les moustiques Aedes, très présente dans les zones tropicales.',
        pointsCles: [
          'Éliminez les eaux stagnantes autour de chez vous',
          'Utilisez des moustiquaires imprégnées',
          'Portez des vêtements longs et clairs',
          'Appliquez des répulsifs anti-moustiques',
          'Dormez sous moustiquaire le jour et la nuit',
          'Consultez rapidement en cas de fièvre élevée',
        ],
        imageIcon: 'bug_report',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 12,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Prévention de la méningite',
        categorie: 'maladies',
        description: 'La méningite est une inflammation des méninges, souvent causée par des infections bactériennes ou virales.',
        pointsCles: [
          'Faites-vous vacciner contre la méningite',
          'Évitez les contacts proches avec les malades',
          'Aérez bien les pièces de vie',
          'Lavez-vous les mains régulièrement',
          'Consultez immédiatement en cas de symptômes',
          'Ne partagez pas les ustensiles de cuisine',
        ],
        imageIcon: 'healing',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 13,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Prévention de la tuberculose',
        categorie: 'maladies',
        description: 'La tuberculose est une infection bactérienne qui touche principalement les poumons mais peut affecter d\'autres organes.',
        pointsCles: [
          'Faites-vous vacciner avec le BCG',
          'Évitez les contacts avec les personnes malades',
          'Aérez régulièrement votre logement',
          'Couvrez votre bouche en toussant',
          'Terminez votre traitement si vous êtes malade',
          'Faites un dépistage régulier si à risque',
        ],
        imageIcon: 'lungs',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 14,
      ),
      ConseilSante(
        id: _uuid.v4(),
        titre: 'Prévention du VIH/SIDA',
        categorie: 'maladies',
        description: 'Le VIH est un virus qui attaque le système immunitaire. La prévention est essentielle pour éviter la transmission.',
        pointsCles: [
          'Utilisez systématiquement des préservatifs',
          'Faites un dépistage régulier',
          'Évitez le partage de seringues',
          'Suivez un traitement si séropositif',
          'Informez-vous sur la transmission mère-enfant',
          'Soutenez les personnes vivant avec le VIH',
        ],
        imageIcon: 'health_and_safety',
        estFavori: false,
        dateCreation: DateTime.now(),
        ordreAffichage: 15,
      ),
    ];

    // Si la box est vide ou si le nombre de conseils est inférieur à 15, on ajoute tous les conseils
    if (conseilsExistants.length < 15) {
      await _conseilsBox.clear();
      for (final conseil in conseils) {
        await _conseilsBox.put(conseil.id, conseil);
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('Prévention & Conseils'),
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategories(),
          Expanded(
            child: _buildConseilsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un conseil...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00A86B)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip('Tous', null, true);
          }
          final category = _categories[index - 1];
          return _buildCategoryChip(
            category.nom,
            Color(int.parse(category.color.replaceFirst('#', '0xFF'))),
            _selectedCategory == category.id,
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, Color? color, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (label == 'Tous') {
              _selectedCategory = 'Tous';
            } else {
              final category = _categories.firstWhere((c) => c.nom == label);
              _selectedCategory = category.id;
            }
          });
        },
        selectedColor: color ?? const Color(0xFF00A86B),
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildConseilsList() {
    return ValueListenableBuilder(
      valueListenable: _conseilsBox.listenable(),
      builder: (context, Box<ConseilSante> box, _) {
        final conseils = box.values.toList()
          ..sort((a, b) => a.ordreAffichage.compareTo(b.ordreAffichage));

        final filteredConseils = conseils.where((conseil) {
          final matchesCategory = _selectedCategory == 'Tous' || conseil.categorie == _selectedCategory;
          final matchesSearch = conseil.titre.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              conseil.description.toLowerCase().contains(_searchController.text.toLowerCase());
          return matchesCategory && matchesSearch;
        }).toList();

        if (filteredConseils.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Aucun conseil trouvé',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredConseils.length,
          itemBuilder: (context, index) {
            final conseil = filteredConseils[index];
            return _buildConseilCard(conseil);
          },
        );
      },
    );
  }

  Widget _buildConseilCard(ConseilSante conseil) {
    final category = _categories.firstWhere(
      (c) => c.id == conseil.categorie,
      orElse: () => _categories[0],
    );
    final categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showConseilDetails(conseil),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconFromString(conseil.imageIcon ?? 'health_and_safety'),
                      color: categoryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conseil.titre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.nom,
                          style: TextStyle(
                            fontSize: 12,
                            color: categoryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      conseil.estFavori ? Icons.favorite : Icons.favorite_border,
                      color: conseil.estFavori ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _toggleFavori(conseil),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                conseil.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConseilDetails(ConseilSante conseil) {
    final category = _categories.firstWhere(
      (c) => c.id == conseil.categorie,
      orElse: () => _categories[0],
    );
    final categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getIconFromString(conseil.imageIcon ?? 'health_and_safety'),
                            color: categoryColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conseil.titre,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.nom,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: categoryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            conseil.estFavori ? Icons.favorite : Icons.favorite_border,
                            color: conseil.estFavori ? Colors.red : Colors.grey,
                            size: 28,
                          ),
                          onPressed: () {
                            _toggleFavori(conseil);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      conseil.description,
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Points clés',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...conseil.pointsCles.map((point) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: categoryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  point,
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFavori(ConseilSante conseil) {
    conseil.estFavori = !conseil.estFavori;
    conseil.save();
    setState(() {});
  }

  IconData _getIconFromString(String iconString) {
    switch (iconString) {
      case 'water_drop':
        return Icons.water_drop;
      case 'wash':
        return Icons.clean_hands;
      case 'pest_control':
        return Icons.pest_control;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'air':
        return Icons.air;
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      case 'vaccines':
        return Icons.vaccines;
      case 'water_damage':
        return Icons.water_damage;
      case 'coronavirus':
        return Icons.coronavirus;
      case 'sick':
        return Icons.sick;
      case 'bug_report':
        return Icons.bug_report;
      case 'healing':
        return Icons.healing;
      case 'lungs':
        return Icons.air;
      case 'health_and_safety':
        return Icons.health_and_safety;
      default:
        return Icons.health_and_safety;
    }
  }
}
