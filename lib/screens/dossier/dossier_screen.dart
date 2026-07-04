import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../models/dossier_model.dart';
import '../../utils/colors.dart';

class DossierScreen extends StatefulWidget {
  const DossierScreen({super.key});

  @override
  State<DossierScreen> createState() => _DossierScreenState();
}

class _DossierScreenState extends State<DossierScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Controllers
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _villeController = TextEditingController();
  final _groupeSanguinController = TextEditingController();
  final _poidsController = TextEditingController();
  final _tailleController = TextEditingController();
  final _traitementsController = TextEditingController();
  final _nomUrgenceController = TextEditingController();
  final _telUrgenceController = TextEditingController();
  
  // Variables
  DateTime? _dateNaissance;
  String _sexe = 'Homme';
  File? _photoProfil;
  final List<String> _allergies = [];
  final List<String> _maladiesChroniques = [];
  final List<String> _vaccinsEffectues = [];
  final Map<String, DateTime?> _vaccinDates = {};
  final List<Map<String, dynamic>> _consultations = [];
  
  // États
  bool _isLoading = false;
  bool _isEditMode = false;
  int _selectedTab = 0;
  String? _userId;
  DossierMedical? _dossierExistant;
  
  // Villes Tchad
  final List<String> _villesTchad = [
    'N\'Djamena', 'Moundou', 'Sarh', 'Abéché',
    'Kélo', 'Doba', 'Bongor', 'Koumra',
    'Am Timan', 'Faya', 'Ati', 'Mongo'
  ];
  
  // Hôpitaux Tchad
  final List<String> _hopitauxTchad = [
    'Hôpital Général de Référence N\'Djamena',
    'Centre Hospitalier Universitaire',
    'Hôpital de Moundou',
    'Hôpital de Sarh',
    'Hôpital d\'Abéché',
    'Centre de Santé',
    'Clinique Privée',
    'Autre'
  ];
  
  // Vaccins
  final List<String> _vaccinsList = [
    'BCG', 'DTP (Diphtérie-Tétanos-Polio)', 'Polio',
    'Hépatite B', 'Méningite A', 'Fièvre jaune',
    'COVID-19', 'Rougeole', 'Tétanos'
  ];
  
  // Maladies chroniques avec labels FR/AR
  final Map<String, String> _maladiesLabels = {
    'Diabète': 'Diabète / السكري',
    'Hypertension': 'Hypertension / ضغط الدم',
    'Drépanocytose': 'Drépanocytose / فقر الدم المنجلي',
    'Asthme': 'Asthme / الربو',
    'VIH/SIDA': 'VIH/SIDA / الإيدز',
    'Tuberculose': 'Tuberculose / السل',
    'Épilepsie': 'Épilepsie / الصرع',
    'Autre': 'Autre / أخرى'
  };
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
    _chargerDossier();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _villeController.dispose();
    _groupeSanguinController.dispose();
    _poidsController.dispose();
    _tailleController.dispose();
    _traitementsController.dispose();
    _nomUrgenceController.dispose();
    _telUrgenceController.dispose();
    super.dispose();
  }

  Future<void> _chargerDossier() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userId = prefs.getString('userId'));
    
    final box = await Hive.openBox<DossierMedical>('dossiers');
    if (_userId != null && box.containsKey(_userId)) {
      setState(() {
        _dossierExistant = box.get(_userId);
        if (_dossierExistant != null) {
          _remplirFormulaire(_dossierExistant!);
          _isEditMode = false;
        }
      });
    }
  }

  void _remplirFormulaire(DossierMedical dossier) {
    _nomController.text = dossier.nom;
    _prenomController.text = dossier.prenom;
    _dateNaissance = dossier.dateNaissance;
    _sexe = dossier.sexe;
    _telephoneController.text = dossier.telephone;
    _villeController.text = dossier.ville;
    _groupeSanguinController.text = dossier.groupeSanguin;
    _poidsController.text = dossier.poids.toString();
    _tailleController.text = dossier.taille.toString();
    _allergies.clear();
    _allergies.addAll(dossier.allergies);
    _maladiesChroniques.clear();
    _maladiesChroniques.addAll(dossier.maladiesChroniques);
    _traitementsController.text = dossier.traitementsEnCours;
    _nomUrgenceController.text = dossier.nomContactUrgence;
    _telUrgenceController.text = dossier.telContactUrgence;
    _vaccinsEffectues.clear();
    _vaccinsEffectues.addAll(dossier.vaccinsEffectues);
    
    // Charger consultations depuis JSON si présentes
    if (dossier.consultationsJson.isNotEmpty) {
      for (var json in dossier.consultationsJson) {
        try {
          // Parser JSON et ajouter à _consultations
          // Pour l'instant, on utilise une structure simple
        } catch (e) {
          print('Erreur parsing consultation: $e');
        }
      }
    }
  }

  void _activerModeEdition() {
    setState(() => _isEditMode = true);
  }

  void _annulerEdition() {
    if (_dossierExistant != null) {
      _remplirFormulaire(_dossierExistant!);
    } else {
      _allergies.clear();
      _maladiesChroniques.clear();
      _vaccinsEffectues.clear();
      _consultations.clear();
    }
    setState(() => _isEditMode = false);
  }

  Future<void> _sauvegarderDossier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final box = await Hive.openBox<DossierMedical>('dossiers');
      
      final dossier = DossierMedical(
        id: _dossierExistant?.id ?? _uuid.v4(),
        nom: _nomController.text,
        prenom: _prenomController.text,
        dateNaissance: _dateNaissance ?? DateTime.now(),
        sexe: _sexe,
        telephone: _telephoneController.text,
        ville: _villeController.text,
        groupeSanguin: _groupeSanguinController.text,
        poids: double.tryParse(_poidsController.text) ?? 0,
        taille: double.tryParse(_tailleController.text) ?? 0,
        allergies: List.from(_allergies),
        maladiesChroniques: List.from(_maladiesChroniques),
        traitementsEnCours: _traitementsController.text,
        nomContactUrgence: _nomUrgenceController.text,
        telContactUrgence: _telUrgenceController.text,
        vaccinsEffectues: List.from(_vaccinsEffectues),
        consultationsJson: [], // À implémenter avec JSON
        dateCreation: _dossierExistant?.dateCreation ?? DateTime.now(),
      );

      if (_userId != null) {
        await box.put(_userId, dossier);
      } else {
        await box.add(dossier);
      }

      setState(() {
        _isLoading = false;
        _dossierExistant = dossier;
        _isEditMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Profil sauvegardé avec succès !'),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sauvegarde: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _choisirPhoto() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _photoProfil = File(image.path));
    }
  }

  Future<void> _selectionnerDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateNaissance = picked);
    }
  }

  Future<void> _appelerUrgence() async {
    final tel = _telUrgenceController.text;
    if (tel.isNotEmpty) {
      final url = 'tel:$tel';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  int _calculerAge() {
    if (_dateNaissance == null) return 0;
    final now = DateTime.now();
    int age = now.year - _dateNaissance!.year;
    if (now.month < _dateNaissance!.month || 
        (now.month == _dateNaissance!.month && now.day < _dateNaissance!.day)) {
      age--;
    }
    return age;
  }

  double _calculerIMC() {
    final poids = double.tryParse(_poidsController.text) ?? 0;
    final taille = double.tryParse(_tailleController.text) ?? 0;
    if (poids > 0 && taille > 0) {
      return poids / ((taille / 100) * (taille / 100));
    }
    return 0;
  }

  Color _getCouleurIMC() {
    final imc = _calculerIMC();
    if (imc >= 18.5 && imc < 25) return AppColors.primary;
    if (imc >= 25 && imc < 30) return AppColors.warning;
    if (imc >= 30) return AppColors.danger;
    return AppColors.textMedium;
  }

  String _getTexteIMC() {
    final imc = _calculerIMC();
    if (imc >= 18.5 && imc < 25) return 'Normal';
    if (imc >= 25 && imc < 30) return 'Surpoids';
    if (imc >= 30) return 'Obésité';
    return 'Non calculé';
  }

  void _ajouterAllergie() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une allergie'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nom de l\'allergie'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _allergies.add(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _supprimerAllergie(int index) {
    setState(() => _allergies.removeAt(index));
  }

  void _toggleMaladie(String maladie) {
    setState(() {
      if (_maladiesChroniques.contains(maladie)) {
        _maladiesChroniques.remove(maladie);
      } else {
        _maladiesChroniques.add(maladie);
      }
    });
  }

  void _toggleVaccin(String vaccin) {
    setState(() {
      if (_vaccinsEffectues.contains(vaccin)) {
        _vaccinsEffectues.remove(vaccin);
        _vaccinDates.remove(vaccin);
      } else {
        _vaccinsEffectues.add(vaccin);
        _vaccinDates[vaccin] = null;
      }
    });
  }

  Future<void> _selectionnerDateVaccin(String vaccin) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _vaccinDates[vaccin] = picked);
    }
  }

  void _ajouterConsultation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildConsultationBottomSheet(),
    );
  }

  Widget _buildConsultationBottomSheet() {
    final medecinController = TextEditingController();
    final hopitalController = TextEditingController();
    final diagnosticController = TextEditingController();
    final traitementController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? dateConsultation = DateTime.now();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajouter une consultation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: dateConsultation,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => dateConsultation = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    '${dateConsultation.day}/${dateConsultation.month}/${dateConsultation.year}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: medecinController,
            decoration: const InputDecoration(
              labelText: 'Nom du médecin',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Hôpital',
              border: OutlineInputBorder(),
            ),
            items: _hopitauxTchad.map((hopital) {
              return DropdownMenuItem(value: hopital, child: Text(hopital));
            }).toList(),
            onChanged: (value) => hopitalController.text = value ?? '',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: diagnosticController,
            decoration: const InputDecoration(
              labelText: 'Diagnostic',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: traitementController,
            decoration: const InputDecoration(
              labelText: 'Traitement',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Notes (optionnel)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (medecinController.text.isNotEmpty && 
                    diagnosticController.text.isNotEmpty) {
                  setState(() {
                    _consultations.add({
                      'date': dateConsultation,
                      'medecin': medecinController.text,
                      'hopital': hopitalController.text,
                      'diagnostic': diagnosticController.text,
                      'traitement': traitementController.text,
                      'notes': notesController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Enregistrer', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _supprimerConsultation(int index) {
    setState(() => _consultations.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfilCard(),
                  const SizedBox(height: 16),
                  _buildTabBar(),
                  const SizedBox(height: 16),
                  _buildTabContent(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedTab == 3
          ? FloatingActionButton(
              onPressed: _ajouterConsultation,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Mon Dossier Médical',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: _activerModeEdition,
              ),
            ],
          ),
          const Text(
            'Vos informations de santé',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilCard() {
    final age = _calculerAge();
    final imc = _calculerIMC();
    final imcCouleur = _getCouleurIMC();
    final imcTexte = _getTexteIMC();
    final initiales = '${_nomController.text.isNotEmpty ? _nomController.text[0] : ''}${_prenomController.text.isNotEmpty ? _prenomController.text[0] : ''}'.toUpperCase();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: _choisirPhoto,
            child: Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: _photoProfil != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Image.file(
                            _photoProfil!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            initiales,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                // Badge groupe sanguin
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      _groupeSanguinController.text.isNotEmpty 
                          ? _groupeSanguinController.text 
                          : 'O+',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Centre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_nomController.text} ${_prenomController.text}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  age > 0 ? '$age ans • $_sexe' : _sexe,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _villeController.text.isNotEmpty ? _villeController.text : 'Non renseigné',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: imcCouleur.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'IMC: ${imc.toStringAsFixed(1)} - $imcTexte',
                    style: TextStyle(
                      fontSize: 12,
                      color: imcCouleur,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Droite
          ElevatedButton(
            onPressed: _activerModeEdition,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Modifier', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMedium,
        tabs: const [
          Tab(text: '👤 Profil'),
          Tab(text: '🏥 Médical'),
          Tab(text: '💉 Vaccins'),
          Tab(text: '📋 Historique'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildProfilTab();
      case 1:
        return _buildMedicalTab();
      case 2:
        return _buildVaccinsTab();
      case 3:
        return _buildHistoriqueTab();
      default:
        return _buildProfilTab();
    }
  }

  Widget _buildProfilTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Identité'),
            const SizedBox(height: 12),
            _buildIdentiteSection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Contact d\'Urgence'),
            const SizedBox(height: 12),
            _buildUrgenceSection(),
            const SizedBox(height: 24),
            _buildSauvegarderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informations Vitales'),
          const SizedBox(height: 12),
          _buildVitalesSection(),
          const SizedBox(height: 24),
          _buildSectionTitle('Groupe Sanguin'),
          const SizedBox(height: 12),
          _buildGroupeSanguinSection(),
          const SizedBox(height: 24),
          _buildSectionTitle('Allergies'),
          const SizedBox(height: 12),
          _buildAllergiesSection(),
          const SizedBox(height: 24),
          _buildSectionTitle('Maladies Chroniques'),
          const SizedBox(height: 12),
          _buildMaladiesSection(),
          const SizedBox(height: 24),
          _buildSectionTitle('Traitements en cours'),
          const SizedBox(height: 12),
          _buildTraitementsSection(),
          const SizedBox(height: 24),
          _buildSauvegarderButton(),
        ],
      ),
    );
  }

  Widget _buildVaccinsTab() {
    final vaccinsEffectuesCount = _vaccinsEffectues.length;
    final progress = vaccinsEffectuesCount / _vaccinsList.length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Résumé
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$vaccinsEffectuesCount / ${_vaccinsList.length} vaccins effectués',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Liste des vaccins'),
          const SizedBox(height: 12),
          ..._vaccinsList.map((vaccin) => _buildVaccinCard(vaccin)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Ajouter vaccin personnalisé
            },
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: const Text('Ajouter un vaccin'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          _buildSauvegarderButton(),
        ],
      ),
    );
  }

  Widget _buildHistoriqueTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Historique des consultations'),
          const SizedBox(height: 12),
          if (_consultations.isEmpty)
            _buildEmptyHistorique()
          else
            ..._consultations.asMap().entries.map((entry) {
              return _buildConsultationCard(entry.key, entry.value);
            }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 50,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentiteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Photo
          GestureDetector(
            onTap: _choisirPhoto,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: _photoProfil != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        _photoProfil!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Stack(
                      children: [
                        Center(
                          child: Text(
                            '${_nomController.text.isNotEmpty ? _nomController.text[0] : ''}${_prenomController.text.isNotEmpty ? _prenomController.text[0] : ''}'.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Nom', _nomController, required: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField('Prénom', _prenomController, required: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectionnerDate,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    _dateNaissance != null
                        ? '${_dateNaissance!.day}/${_dateNaissance!.month}/${_dateNaissance!.year}'
                        : 'Date de naissance',
                    style: TextStyle(
                      color: _dateNaissance != null
                          ? AppColors.textDark
                          : AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _sexe = 'Homme'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _sexe == 'Homme' ? AppColors.primary : Colors.grey[300],
                    foregroundColor: _sexe == 'Homme' ? Colors.white : Colors.black,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('👨'),
                      SizedBox(width: 8),
                      Text('Homme'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _sexe = 'Femme'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _sexe == 'Femme' ? AppColors.primary : Colors.grey[300],
                    foregroundColor: _sexe == 'Femme' ? Colors.white : Colors.black,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('👩'),
                      SizedBox(width: 8),
                      Text('Femme'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('+235', style: TextStyle(color: AppColors.textDark)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField('Téléphone', _telephoneController, keyboardType: TextInputType.phone),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _villeController.text.isEmpty ? null : _villeController.text,
            decoration: const InputDecoration(
              labelText: 'Ville',
              border: OutlineInputBorder(),
            ),
            items: _villesTchad.map((ville) {
              return DropdownMenuItem(value: ville, child: Text(ville));
            }).toList(),
            onChanged: (value) => setState(() => _villeController.text = value ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgenceSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: AppColors.danger),
              const SizedBox(width: 8),
              const Text(
                '🚨 Contact d\'Urgence',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField('Nom du contact', _nomUrgenceController),
          const SizedBox(height: 12),
          InkWell(
            onTap: _appelerUrgence,
            child: Row(
              children: [
                const Icon(Icons.phone, color: AppColors.danger),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField('Téléphone', _telUrgenceController, keyboardType: TextInputType.phone),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalesSection() {
    return Row(
      children: [
        Expanded(
          child: _buildVitaleCard(
            icon: Icons.monitor_weight,
            label: 'Poids',
            value: _poidsController.text,
            unit: 'kg',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildVitaleCard(
            icon: Icons.straighten,
            label: 'Taille',
            value: _tailleController.text,
            unit: 'cm',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildVitaleCard(
            icon: Icons.fitness_center,
            label: 'IMC',
            value: _calculerIMC().toStringAsFixed(1),
            unit: '',
            color: _getCouleurIMC(),
          ),
        ),
      ],
    );
  }

  Widget _buildVitaleCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color ?? AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value $unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupeSanguinSection() {
    final groupes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: groupes.length,
      itemBuilder: (context, index) {
        final groupe = groupes[index];
        final isSelected = _groupeSanguinController.text == groupe;
        
        return InkWell(
          onTap: () => setState(() => _groupeSanguinController.text = groupe),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Center(
              child: Text(
                groupe,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllergiesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_allergies.isEmpty)
            const Text('Aucune allergie connue', style: TextStyle(color: AppColors.textMedium))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allergies.asMap().entries.map((entry) {
                return Chip(
                  label: Text(entry.value),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _supprimerAllergie(entry.key),
                  backgroundColor: AppColors.danger.withOpacity(0.1),
                  deleteIconColor: AppColors.danger,
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _ajouterAllergie,
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: const Text('Ajouter une allergie'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaladiesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _maladiesLabels.entries.map((entry) {
          final maladie = entry.key;
          final label = entry.value;
          final isSelected = _maladiesChroniques.contains(maladie);
          
          return CheckboxListTile(
            value: isSelected,
            onChanged: (_) => _toggleMaladie(maladie),
            title: Text(label),
            activeColor: AppColors.primary,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.leading,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTraitementsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _traitementsController,
        maxLines: 4,
        decoration: const InputDecoration(
          labelText: 'Traitements en cours',
          hintText: 'Médicaments actuels...',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildVaccinCard(String vaccin) {
    final isEffectue = _vaccinsEffectues.contains(vaccin);
    final date = _vaccinDates[vaccin];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Icon(Icons.vaccines, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccin,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (isEffectue && date != null)
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: isEffectue,
            onChanged: (_) => _toggleVaccin(vaccin),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistorique() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.medical_services,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune consultation enregistrée',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Appuyez sur + pour ajouter',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(int index, Map<String, dynamic> consultation) {
    final date = consultation['date'] as DateTime;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.danger, size: 20),
                onPressed: () => _supprimerConsultation(index),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${consultation['medecin']} - ${consultation['hopital']}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            consultation['diagnostic'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (consultation['traitement'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              consultation['traitement'],
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
          ],
          if (consultation['notes'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              consultation['notes'],
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSauvegarderButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sauvegarderDossier,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Sauvegarder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: required ? const Icon(Icons.badge, color: AppColors.primary, size: 20) : null,
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null
          : null,
    );
  }
}
