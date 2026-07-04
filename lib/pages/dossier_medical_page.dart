import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/dossier_model.dart';
import '../utils/colors.dart';

class DossierMedicalPage extends StatefulWidget {
  const DossierMedicalPage({super.key});

  @override
  State<DossierMedicalPage> createState() => _DossierMedicalPageState();
}

class _DossierMedicalPageState extends State<DossierMedicalPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  
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
  
  DateTime? _dateNaissance;
  String _sexe = 'Homme';
  final List<String> _allergies = [];
  final List<String> _selectedAllergies = [];
  final List<String> _maladiesChroniques = [];
  final List<String> _selectedMaladies = [];
  final List<String> _vaccinsEffectues = [];
  final List<String> _selectedVaccins = [];
  final List<String> _consultationsJson = [];
  
  bool _isLoading = false;
  bool _isEditMode = false;
  DossierMedical? _dossierExistant;

  @override
  void initState() {
    super.initState();
    _chargerDossier();
  }

  @override
  void dispose() {
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
    final box = await Hive.openBox<DossierMedical>('dossiers');
    if (box.isNotEmpty) {
      setState(() {
        _dossierExistant = box.getAt(0);
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
    _selectedAllergies.clear();
    _selectedAllergies.addAll(dossier.allergies);
    _maladiesChroniques.clear();
    _maladiesChroniques.addAll(dossier.maladiesChroniques);
    _selectedMaladies.clear();
    _selectedMaladies.addAll(dossier.maladiesChroniques);
    _traitementsController.text = dossier.traitementsEnCours;
    _nomUrgenceController.text = dossier.nomContactUrgence;
    _telUrgenceController.text = dossier.telContactUrgence;
    _vaccinsEffectues.clear();
    _vaccinsEffectues.addAll(dossier.vaccinsEffectues);
    _selectedVaccins.clear();
    _selectedVaccins.addAll(dossier.vaccinsEffectues);
    _consultationsJson.clear();
    _consultationsJson.addAll(dossier.consultationsJson);
  }

  void _activerModeEdition() {
    setState(() => _isEditMode = true);
  }

  void _annulerEdition() {
    if (_dossierExistant != null) {
      _remplirFormulaire(_dossierExistant!);
    } else {
      _selectedAllergies.clear();
      _selectedMaladies.clear();
      _selectedVaccins.clear();
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
        allergies: List.from(_selectedAllergies),
        maladiesChroniques: List.from(_selectedMaladies),
        traitementsEnCours: _traitementsController.text,
        nomContactUrgence: _nomUrgenceController.text,
        telContactUrgence: _telUrgenceController.text,
        vaccinsEffectues: List.from(_selectedVaccins),
        consultationsJson: List.from(_consultationsJson),
        dateCreation: _dossierExistant?.dateCreation ?? DateTime.now(),
      );

      if (_dossierExistant != null) {
        await box.putAt(0, dossier);
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
          content: Text('Dossier médical sauvegardé avec succès'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    if (_dossierExistant != null && !_isEditMode) {
      return _buildAffichageDossier();
    }
    return _buildFormulaire();
  }

  Widget _buildAffichageDossier() {
    final dossier = _dossierExistant!;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('Mon Dossier Médical'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _activerModeEdition,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('IDENTITÉ', [
              _buildInfoRow('Nom', dossier.nom.isEmpty ? 'Non renseigné' : dossier.nom),
              _buildInfoRow('Prénom', dossier.prenom.isEmpty ? 'Non renseigné' : dossier.prenom),
              _buildInfoRow('Date de naissance', '${dossier.dateNaissance.day}/${dossier.dateNaissance.month}/${dossier.dateNaissance.year}'),
              _buildInfoRow('Sexe', dossier.sexe),
              _buildInfoRow('Téléphone', dossier.telephone.isEmpty ? 'Non renseigné' : dossier.telephone),
              _buildInfoRow('Ville', dossier.ville.isEmpty ? 'Non renseigné' : dossier.ville),
            ]),
            const SizedBox(height: 16),
            
            _buildInfoCard('INFORMATIONS MÉDICALES', [
              _buildInfoRow('Groupe sanguin', dossier.groupeSanguin.isEmpty ? 'Non renseigné' : dossier.groupeSanguin),
              _buildInfoRow('Poids', dossier.poids > 0 ? '${dossier.poids} kg' : 'Non renseigné'),
              _buildInfoRow('Taille', dossier.taille > 0 ? '${dossier.taille} cm' : 'Non renseigné'),
            ]),
            const SizedBox(height: 16),
            
            _buildInfoCard('ALLERGIES', _selectedAllergies.isEmpty
                ? [const Text('Aucune allergie', style: TextStyle(color: AppColors.textMedium))]
                : _selectedAllergies.map((a) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(a),
                      ],
                    ),
                  )).toList()),
            const SizedBox(height: 16),
            
            _buildInfoCard('MALADIES CHRONIQUES', _selectedMaladies.isEmpty
                ? [const Text('Aucune maladie chronique', style: TextStyle(color: AppColors.textMedium))]
                : _selectedMaladies.map((m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(m),
                      ],
                    ),
                  )).toList()),
            const SizedBox(height: 16),
            
            _buildInfoCard('TRAITEMENTS EN COURS', [
              Text(dossier.traitementsEnCours.isEmpty ? 'Aucun traitement' : dossier.traitementsEnCours),
            ]),
            const SizedBox(height: 16),
            
            _buildInfoCard('CONTACT URGENCE', [
              _buildInfoRow('Nom', dossier.nomContactUrgence.isEmpty ? 'Non renseigné' : dossier.nomContactUrgence),
              _buildInfoRow('Téléphone', dossier.telContactUrgence.isEmpty ? 'Non renseigné' : dossier.telContactUrgence),
            ]),
            const SizedBox(height: 16),
            
            _buildInfoCard('VACCINATIONS EFFECTUÉES', _selectedVaccins.isEmpty
                ? [const Text('Aucun vaccin renseigné', style: TextStyle(color: AppColors.textMedium))]
                : _selectedVaccins.map((v) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(v),
                      ],
                    ),
                  )).toList()),
            const SizedBox(height: 16),
            
            _buildInfoCard('DATE DE CRÉATION', [
              _buildInfoRow('', '${dossier.dateCreation.day}/${dossier.dateCreation.month}/${dossier.dateCreation.year}'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaire() {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(_dossierExistant == null ? 'Créer Dossier Médical' : 'Modifier Dossier Médical'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: _dossierExistant != null
            ? [
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: _annulerEdition,
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('IDENTITÉ'),
              const SizedBox(height: 12),
              _buildIdentiteSection(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('INFORMATIONS MÉDICALES'),
              const SizedBox(height: 12),
              _buildMedicalSection(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('ALLERGIES'),
              const SizedBox(height: 12),
              _buildAllergiesSection(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('MALADIES CHRONIQUES'),
              const SizedBox(height: 12),
              _buildMaladiesSection(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('TRAITEMENTS EN COURS'),
              const SizedBox(height: 12),
              _buildTraitementsSection(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('CONTACT URGENCE'),
              const SizedBox(height: 12),
              _buildUrgenceSection(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('VACCINATIONS EFFECTUÉES'),
              const SizedBox(height: 12),
              _buildVaccinsSection(),
              const SizedBox(height: 32),
              
              _buildSauvegarderButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildIdentiteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
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
              const Text('Sexe: ', style: TextStyle(fontSize: 16)),
              Radio<String>(
                value: 'Homme',
                groupValue: _sexe,
                onChanged: (value) => setState(() => _sexe = value!),
                activeColor: AppColors.primary,
              ),
              const Text('Homme'),
              Radio<String>(
                value: 'Femme',
                groupValue: _sexe,
                onChanged: (value) => setState(() => _sexe = value!),
                activeColor: AppColors.primary,
              ),
              const Text('Femme'),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField('Téléphone', _telephoneController, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _buildTextField('Ville', _villeController),
        ],
      ),
    );
  }

  Widget _buildMedicalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
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
          DropdownButtonFormField<String>(
            value: _groupeSanguinController.text.isEmpty ? null : _groupeSanguinController.text,
            decoration: const InputDecoration(
              labelText: 'Groupe sanguin',
              border: OutlineInputBorder(),
            ),
            items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((groupe) {
              return DropdownMenuItem(value: groupe, child: Text(groupe));
            }).toList(),
            onChanged: (value) {
              setState(() => _groupeSanguinController.text = value!);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Poids (kg)', _poidsController, keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField('Taille (cm)', _tailleController, keyboardType: TextInputType.number),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesSection() {
    final allergieOptions = [
      'Arachides', 'Fruits de mer', 'Lait', 'Œufs', 'Soja', 'Blé',
      'Pollen', 'Acariens', 'Poils animaux', 'Latex', 'Médicaments', 'Autre'
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
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
          const Text('Allergies', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_selectedAllergies.isEmpty)
            const Text('Aucune allergie sélectionnée', style: TextStyle(color: AppColors.textMedium))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedAllergies.map((a) => Chip(
                label: Text(a),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() => _selectedAllergies.remove(a));
                },
                backgroundColor: AppColors.danger.withOpacity(0.1),
                deleteIconColor: AppColors.danger,
              )).toList(),
            ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Ajouter une allergie',
              border: OutlineInputBorder(),
            ),
            items: allergieOptions.map((allergie) {
              return DropdownMenuItem(
                value: allergie,
                child: Text(allergie),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null && !_selectedAllergies.contains(value)) {
                setState(() => _selectedAllergies.add(value));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaladiesSection() {
    final maladieOptions = [
      'Diabète', 'Hypertension', 'Drépanocytose', 'Asthme',
      'VIH', 'Tuberculose', 'Épilepsie', 'Maladies cardiaques',
      'Maladies rénales', 'Cancer', 'Autre'
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
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
          const Text('Maladies chroniques', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_selectedMaladies.isEmpty)
            const Text('Aucune maladie chronique sélectionnée', style: TextStyle(color: AppColors.textMedium))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedMaladies.map((m) => Chip(
                label: Text(m),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() => _selectedMaladies.remove(m));
                },
                backgroundColor: AppColors.warning.withOpacity(0.1),
                deleteIconColor: AppColors.warning,
              )).toList(),
            ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Ajouter une maladie chronique',
              border: OutlineInputBorder(),
            ),
            items: maladieOptions.map((maladie) {
              return DropdownMenuItem(
                value: maladie,
                child: Text(maladie),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null && !_selectedMaladies.contains(value)) {
                setState(() => _selectedMaladies.add(value));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTraitementsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
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
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Traitements en cours',
          hintText: 'Listez vos traitements médicaux actuels...',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildUrgenceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
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
          _buildTextField('Nom du contact urgence', _nomUrgenceController),
          const SizedBox(height: 12),
          _buildTextField('Téléphone du contact urgence', _telUrgenceController, keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _buildVaccinsSection() {
    final vaccinOptions = [
      'BCG', 'DTCoq', 'ROR', 'Hépatite B', 'VPO', 'Fièvre jaune',
      'Pneumocoque', 'RORV', 'HPV', 'Grippe', 'COVID-19', 'Méningite',
      'Typhoïde', 'Rage', 'Choléra', 'Autre'
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
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
          const Text('Vaccinations effectuées', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_selectedVaccins.isEmpty)
            const Text('Aucun vaccin sélectionné', style: TextStyle(color: AppColors.textMedium))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedVaccins.map((v) => Chip(
                label: Text(v),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() => _selectedVaccins.remove(v));
                },
                backgroundColor: AppColors.primary.withOpacity(0.1),
                deleteIconColor: AppColors.primary,
              )).toList(),
            ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Ajouter un vaccin',
              border: OutlineInputBorder(),
            ),
            items: vaccinOptions.map((vaccin) {
              return DropdownMenuItem(
                value: vaccin,
                child: Text(vaccin),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null && !_selectedVaccins.contains(value)) {
                setState(() => _selectedVaccins.add(value));
              }
            },
          ),
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
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : const Text(
                'SAUVEGARDER LE DOSSIER',
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
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null
          : null,
    );
  }
}
