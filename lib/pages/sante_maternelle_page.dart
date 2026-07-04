import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/sante_maternelle_model.dart';
import '../utils/colors.dart';

class SanteMaternellePage extends StatefulWidget {
  const SanteMaternellePage({super.key});

  @override
  State<SanteMaternellePage> createState() => _SanteMaternellePageState();
}

class _SanteMaternellePageState extends State<SanteMaternellePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _uuid = const Uuid();

  late Box<Grossesse> _grossessesBox;
  late Box<VisitePrenatale> _visitesBox;
  late Box<Enfant> _enfantsBox;
  late Box<Vaccination> _vaccinationsBox;
  late Box<SuiviCroissance> _suiviCroissanceBox;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _grossessesBox = Hive.box<Grossesse>('grossesses');
    _visitesBox = Hive.box<VisitePrenatale>('visites_prenatales');
    _enfantsBox = Hive.box<Enfant>('enfants');
    _vaccinationsBox = Hive.box<Vaccination>('vaccinations');
    _suiviCroissanceBox = Hive.box<SuiviCroissance>('suivi_croissance');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('Suivi Maternel & Infantile'),
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Grossesses'),
            Tab(text: 'Enfants'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGrossessesTab(),
          _buildEnfantsTab(),
        ],
      ),
    );
  }

  Widget _buildGrossessesTab() {
    return ValueListenableBuilder(
      valueListenable: _grossessesBox.listenable(),
      builder: (context, Box<Grossesse> box, _) {
        final grossesses = box.values.toList()
          ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));

        if (grossesses.isEmpty) {
          return _buildEmptyGrossesses();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: grossesses.length,
          itemBuilder: (context, index) {
            final grossesse = grossesses[index];
            return _buildGrossesseCard(grossesse);
          },
        );
      },
    );
  }

  Widget _buildEmptyGrossesses() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pregnant_woman, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune grossesse enregistrée',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre première grossesse',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddGrossesseDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une grossesse'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A86B),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrossesseCard(Grossesse grossesse) {
    final semaines = grossesse.semainesGrossesse;
    final joursRestants = grossesse.joursRestants;
    final trimestre = grossesse.trimestre;

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
        onTap: () => _showGrossesseDetails(grossesse),
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
                      color: const Color(0xFF00A86B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: grossesse.estTerminee
                        ? const Icon(Icons.check_circle, color: Color(0xFF00A86B), size: 28)
                        : const Icon(Icons.pregnant_woman, color: Color(0xFF00A86B), size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grossesse.estTerminee ? 'Grossesse terminée' : 'Grossesse en cours',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Début: ${_formatDate(grossesse.dateDebut)}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: grossesse.estTerminee ? Colors.grey : const Color(0xFFE91E63),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trimestre,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (!grossesse.estTerminee) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Semaines',
                        '$semaines SA',
                        Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Jours restants',
                        '$joursRestants',
                        Icons.access_time,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Accouchement prévu: ${_formatDate(grossesse.dateAccouchementPrevue)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF00A86B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00A86B), size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00A86B),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEnfantsTab() {
    return ValueListenableBuilder(
      valueListenable: _enfantsBox.listenable(),
      builder: (context, Box<Enfant> box, _) {
        final enfants = box.values.toList()
          ..sort((a, b) => b.dateNaissance.compareTo(a.dateNaissance));

        if (enfants.isEmpty) {
          return _buildEmptyEnfants();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: enfants.length,
          itemBuilder: (context, index) {
            final enfant = enfants[index];
            return _buildEnfantCard(enfant);
          },
        );
      },
    );
  }

  Widget _buildEmptyEnfants() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun enfant enregistré',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez le suivi de vos enfants',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEnfantDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un enfant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A86B),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnfantCard(Enfant enfant) {
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
        onTap: () => _showEnfantDetails(enfant),
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
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      enfant.sexe == 'M' ? Icons.boy : Icons.girl,
                      color: const Color(0xFF2196F3),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enfant.nom,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          enfant.ageText,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: enfant.sexe == 'M' ? Colors.blue : Colors.pink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      enfant.sexe == 'M' ? 'Garçon' : 'Fille',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Né(e) le: ${_formatDate(enfant.dateNaissance)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(Icons.monitor_weight, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${enfant.poidsNaissance} kg',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddGrossesseDialog() {
    final dateDebutController = TextEditingController();
    final groupeSanguinController = TextEditingController(text: 'O+');
    final enfantsPrecedentsController = TextEditingController(text: '0');
    String facteursRisques = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouvelle Grossesse'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Date des dernières règles'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 280)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      dateDebutController.text = _formatDate(date);
                      setDialogState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFF00A86B)),
                        const SizedBox(width: 8),
                        Text(
                          dateDebutController.text.isEmpty
                              ? 'Sélectionner une date'
                              : dateDebutController.text,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Groupe sanguin'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: groupeSanguinController.text,
                  items: const [
                    DropdownMenuItem(value: 'O+', child: Text('O+')),
                    DropdownMenuItem(value: 'O-', child: Text('O-')),
                    DropdownMenuItem(value: 'A+', child: Text('A+')),
                    DropdownMenuItem(value: 'A-', child: Text('A-')),
                    DropdownMenuItem(value: 'B+', child: Text('B+')),
                    DropdownMenuItem(value: 'B-', child: Text('B-')),
                    DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                    DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                  ],
                  onChanged: (value) => setDialogState(() => groupeSanguinController.text = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: enfantsPrecedentsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nombre d\'enfants précédents',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Facteurs de risque (optionnel)'),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => facteursRisques = value,
                  decoration: const InputDecoration(
                    hintText: 'Diabète, hypertension, etc.',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dateDebutController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez sélectionner une date')),
                  );
                  return;
                }

                final dateDebut = _parseDate(dateDebutController.text);
                final dateAccouchementPrevue = dateDebut.add(const Duration(days: 280));

                final grossesse = Grossesse(
                  id: _uuid.v4(),
                  dateDebut: dateDebut,
                  dateAccouchementPrevue: dateAccouchementPrevue,
                  nombreEnfantsPrecedents: int.tryParse(enfantsPrecedentsController.text) ?? 0,
                  groupeSanguin: groupeSanguinController.text,
                  facteursRisques: facteursRisques.isEmpty ? null : facteursRisques,
                  estTerminee: false,
                  dateCreation: DateTime.now(),
                );

                _grossessesBox.put(grossesse.id, grossesse);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEnfantDialog() {
    final nomController = TextEditingController();
    final dateNaissanceController = TextEditingController();
    final poidsController = TextEditingController();
    final tailleController = TextEditingController();
    String sexe = 'M';
    String groupeSanguin = 'O+';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouvel Enfant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'enfant',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Date de naissance'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      dateNaissanceController.text = _formatDate(date);
                      setDialogState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFF00A86B)),
                        const SizedBox(width: 8),
                        Text(
                          dateNaissanceController.text.isEmpty
                              ? 'Sélectionner une date'
                              : dateNaissanceController.text,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Garçon'),
                        value: 'M',
                        groupValue: sexe,
                        onChanged: (value) => setDialogState(() => sexe = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Fille'),
                        value: 'F',
                        groupValue: sexe,
                        onChanged: (value) => setDialogState(() => sexe = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: poidsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Poids (kg)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: tailleController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Taille (cm)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Groupe sanguin'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: groupeSanguin,
                  items: const [
                    DropdownMenuItem(value: 'O+', child: Text('O+')),
                    DropdownMenuItem(value: 'O-', child: Text('O-')),
                    DropdownMenuItem(value: 'A+', child: Text('A+')),
                    DropdownMenuItem(value: 'A-', child: Text('A-')),
                    DropdownMenuItem(value: 'B+', child: Text('B+')),
                    DropdownMenuItem(value: 'B-', child: Text('B-')),
                    DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                    DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                  ],
                  onChanged: (value) => setDialogState(() => groupeSanguin = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nomController.text.isEmpty || dateNaissanceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir tous les champs')),
                  );
                  return;
                }

                final enfant = Enfant(
                  id: _uuid.v4(),
                  nom: nomController.text,
                  dateNaissance: _parseDate(dateNaissanceController.text),
                  poidsNaissance: double.tryParse(poidsController.text) ?? 3.0,
                  tailleNaissance: double.tryParse(tailleController.text) ?? 50.0,
                  sexe: sexe,
                  groupeSanguin: groupeSanguin,
                  dateCreation: DateTime.now(),
                );

                _enfantsBox.put(enfant.id, enfant);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGrossesseDetails(Grossesse grossesse) {
    final visites = _visitesBox.values
        .where((v) => v.grossesseId == grossesse.id)
        .toList()
      ..sort((a, b) => b.dateVisite.compareTo(a.dateVisite));

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
                            color: const Color(0xFF00A86B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: grossesse.estTerminee
                              ? const Icon(Icons.check_circle, color: Color(0xFF00A86B), size: 32)
                              : const Icon(Icons.pregnant_woman, color: Color(0xFF00A86B), size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                grossesse.estTerminee ? 'Grossesse terminée' : 'Grossesse en cours',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                grossesse.trimestre,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (!grossesse.estTerminee) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailStat(
                              'Semaines',
                              '${grossesse.semainesGrossesse} SA',
                              Icons.calendar_today,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailStat(
                              'Jours restants',
                              '${grossesse.joursRestants}',
                              Icons.access_time,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildDetailRow(Icons.event, 'Date de début', _formatDate(grossesse.dateDebut)),
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.event_available, 'Accouchement prévu', _formatDate(grossesse.dateAccouchementPrevue)),
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.bloodtype, 'Groupe sanguin', grossesse.groupeSanguin),
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.family_restroom, 'Enfants précédents', '${grossesse.nombreEnfantsPrecedents}'),
                    if (grossesse.facteursRisques != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailRow(Icons.warning, 'Facteurs de risque', grossesse.facteursRisques!),
                    ],
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Visites prénatales',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddVisiteDialog(grossesse.id),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Ajouter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A86B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (visites.isEmpty)
                      const Text('Aucune visite enregistrée')
                    else
                      ...visites.map((visite) => _buildVisiteCard(visite)),
                    const SizedBox(height: 24),
                    if (!grossesse.estTerminee)
                      ElevatedButton.icon(
                        onPressed: () => _terminerGrossesse(grossesse),
                        icon: const Icon(Icons.check),
                        label: const Text('Marquer comme terminée'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnfantDetails(Enfant enfant) {
    final vaccinations = _vaccinationsBox.values
        .where((v) => v.enfantId == enfant.id)
        .toList()
      ..sort((a, b) => a.datePrevue.compareTo(b.datePrevue));

    final suivi = _suiviCroissanceBox.values
        .where((s) => s.enfantId == enfant.id)
        .toList()
      ..sort((a, b) => b.dateMesure.compareTo(a.dateMesure));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => DefaultTabController(
          length: 2,
          child: Container(
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          enfant.sexe == 'M' ? Icons.boy : Icons.girl,
                          color: const Color(0xFF2196F3),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              enfant.nom,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              enfant.ageText,
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(text: 'Vaccinations'),
                    Tab(text: 'Croissance'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildVaccinationsTab(enfant, vaccinations),
                      _buildCroissanceTab(enfant, suivi),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVaccinationsTab(Enfant enfant, List<Vaccination> vaccinations) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Calendrier vaccinal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddVaccinationDialog(enfant.id),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (vaccinations.isEmpty)
          const Text('Aucune vaccination enregistrée')
        else
          ...vaccinations.map((vaccin) => _buildVaccinationCard(vaccin)),
      ],
    );
  }

  Widget _buildCroissanceTab(Enfant enfant, List<SuiviCroissance> suivi) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Suivi de croissance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddSuiviCroissanceDialog(enfant.id),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (suivi.isEmpty)
          const Text('Aucune mesure enregistrée')
        else
          ...suivi.map((mesure) => _buildSuiviCroissanceCard(mesure)),
      ],
    );
  }

  Widget _buildVisiteCard(VisitePrenatale visite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(visite.dateVisite),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (visite.examensEffectues)
                const Icon(Icons.check_circle, color: Color(0xFF00A86B), size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.monitor_weight, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${visite.poids} kg'),
              const SizedBox(width: 16),
              Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${visite.tensionArterielle} mmHg'),
            ],
          ),
          if (visite.notes != null) ...[
            const SizedBox(height: 8),
            Text(visite.notes!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ],
      ),
    );
  }

  Widget _buildVaccinationCard(Vaccination vaccin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: vaccin.estAdministre
            ? const Color(0xFF00A86B).withOpacity(0.1)
            : vaccin.estEnRetard
                ? Colors.red.withOpacity(0.1)
                : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: vaccin.estAdministre
              ? const Color(0xFF00A86B)
              : vaccin.estEnRetard
                  ? Colors.red
                  : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            vaccin.estAdministre ? Icons.check_circle : vaccin.estEnRetard ? Icons.warning : Icons.schedule,
            color: vaccin.estAdministre
                ? const Color(0xFF00A86B)
                : vaccin.estEnRetard
                    ? Colors.red
                    : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccin.nomVaccin,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Prévu: ${_formatDate(vaccin.datePrevue)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (!vaccin.estAdministre)
            IconButton(
              icon: const Icon(Icons.check, size: 20),
              onPressed: () => _marquerVaccinationAdministree(vaccin),
              color: const Color(0xFF00A86B),
            ),
        ],
      ),
    );
  }

  Widget _buildSuiviCroissanceCard(SuiviCroissance mesure) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(mesure.dateMesure),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.monitor_weight, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${mesure.poids} kg'),
              const SizedBox(width: 16),
              Icon(Icons.height, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${mesure.taille} cm'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00A86B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00A86B), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00A86B),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF00A86B), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddVisiteDialog(String grossesseId) {
    final poidsController = TextEditingController();
    final tensionController = TextEditingController();
    final notesController = TextEditingController();
    bool examensEffectues = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouvelle visite prénatale'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: poidsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Poids (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tensionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tension artérielle (mmHg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Examens effectués'),
                value: examensEffectues,
                onChanged: (value) => setDialogState(() => examensEffectues = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final visite = VisitePrenatale(
                  id: _uuid.v4(),
                  grossesseId: grossesseId,
                  dateVisite: DateTime.now(),
                  poids: double.tryParse(poidsController.text) ?? 0,
                  tensionArterielle: double.tryParse(tensionController.text) ?? 0,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                  examensEffectues: examensEffectues,
                  dateCreation: DateTime.now(),
                );

                _visitesBox.put(visite.id, visite);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVaccinationDialog(String enfantId) {
    final nomController = TextEditingController();
    DateTime datePrevue = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouvelle vaccination'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom du vaccin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Date prévue'),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: datePrevue,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (date != null) {
                    setDialogState(() => datePrevue = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF00A86B)),
                      const SizedBox(width: 8),
                      Text(_formatDate(datePrevue)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final vaccin = Vaccination(
                  id: _uuid.v4(),
                  enfantId: enfantId,
                  nomVaccin: nomController.text,
                  datePrevue: datePrevue,
                  estAdministre: false,
                  dateCreation: DateTime.now(),
                );

                _vaccinationsBox.put(vaccin.id, vaccin);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSuiviCroissanceDialog(String enfantId) {
    final poidsController = TextEditingController();
    final tailleController = TextEditingController();
    final perimetreController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle mesure'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: poidsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Poids (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tailleController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Taille (cm)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: perimetreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Périmètre crânien (cm) - optionnel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final mesure = SuiviCroissance(
                id: _uuid.v4(),
                enfantId: enfantId,
                dateMesure: DateTime.now(),
                poids: double.tryParse(poidsController.text) ?? 0,
                taille: double.tryParse(tailleController.text) ?? 0,
                perimetreCranien: perimetreController.text.isEmpty
                    ? null
                    : double.tryParse(perimetreController.text),
                notes: notesController.text.isEmpty ? null : notesController.text,
                dateCreation: DateTime.now(),
              );

              _suiviCroissanceBox.put(mesure.id, mesure);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A86B),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _marquerVaccinationAdministree(Vaccination vaccin) {
    vaccin.estAdministre = true;
    vaccin.dateAdministree = DateTime.now();
    vaccin.save();
    setState(() {});
  }

  void _terminerGrossesse(Grossesse grossesse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer la grossesse'),
        content: const Text('Voulez-vous marquer cette grossesse comme terminée ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              grossesse.estTerminee = true;
              grossesse.dateAccouchementReelle = DateTime.now();
              grossesse.save();
              Navigator.pop(context);
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }
}
