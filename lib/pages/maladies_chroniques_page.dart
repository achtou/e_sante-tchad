import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/maladie_chronique_model.dart';
import '../utils/colors.dart';

class MaladiesChroniquesPage extends StatefulWidget {
  const MaladiesChroniquesPage({super.key});

  @override
  State<MaladiesChroniquesPage> createState() => _MaladiesChroniquesPageState();
}

class _MaladiesChroniquesPageState extends State<MaladiesChroniquesPage> {
  final _uuid = const Uuid();
  late Box<MaladieChronique> _maladiesBox;
  
  final _nomController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _medecinController = TextEditingController();
  final _telMedecinController = TextEditingController();
  final List<String> _traitements = [];
  final TextEditingController _traitementController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _maladiesBox = Hive.box<MaladieChronique>('maladies_chroniques');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _medecinController.dispose();
    _telMedecinController.dispose();
    _traitementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('Suivi des Maladies Chroniques'),
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: _maladiesBox.listenable(),
        builder: (context, Box<MaladieChronique> box, _) {
          final maladies = box.values.toList()
            ..sort((a, b) => b.dateDiagnostic.compareTo(a.dateDiagnostic));

          if (maladies.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: maladies.length,
            itemBuilder: (context, index) {
              final maladie = maladies[index];
              return _buildMaladieCard(maladie);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMaladieDialog(),
        backgroundColor: const Color(0xFF00A86B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_information, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune maladie chronique enregistrée',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Cliquez sur + pour ajouter une maladie',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMaladieCard(MaladieChronique maladie) {
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
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getTypeColor(maladie.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTypeIcon(maladie.type),
                color: _getTypeColor(maladie.type),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    maladie.nom,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Diagnostiqué le ${maladie.dateDiagnostic.day}/${maladie.dateDiagnostic.month}/${maladie.dateDiagnostic.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSection('Description', maladie.description),
                const SizedBox(height: 12),
                _buildDetailSection('Traitements', maladie.traitements.isEmpty ? 'Aucun' : maladie.traitements.join(', ')),
                const SizedBox(height: 12),
                _buildDetailSection('Médecin traitant', '${maladie.medecinTraitant} (${maladie.telephoneMedecin})'),
                const SizedBox(height: 12),
                _buildMesuresSection(maladie),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddMesureDialog(maladie),
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter une mesure'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A86B),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteMaladie(maladie.id),
                        icon: const Icon(Icons.delete),
                        label: const Text('Supprimer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String value) {
    return Column(
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
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildMesuresSection(MaladieChronique maladie) {
    if (maladie.mesures.isEmpty) {
      return const Text('Aucune mesure enregistrée', style: TextStyle(color: Colors.grey));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mesures récentes',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        ...maladie.mesures.take(5).map((mesure) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(_getMesureIcon(mesure.type), size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text('${mesure.type}: ${mesure.valeur.toStringAsFixed(1)}'),
              const Spacer(),
              Text(
                '${mesure.date.day}/${mesure.date.month}/${mesure.date.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        )),
      ],
    );
  }

  void _showAddMaladieDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une maladie chronique'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la maladie',
                  hintText: 'Ex: Diabète de type 2',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _typeController.text.isEmpty ? null : _typeController.text,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'diabete', child: Text('Diabète')),
                  DropdownMenuItem(value: 'hypertension', child: Text('Hypertension')),
                  DropdownMenuItem(value: 'asthme', child: Text('Asthme')),
                  DropdownMenuItem(value: 'cardiaque', child: Text('Maladie cardiaque')),
                  DropdownMenuItem(value: 'rein', child: Text('Maladie rénale')),
                  DropdownMenuItem(value: 'autre', child: Text('Autre')),
                ],
                onChanged: (value) => _typeController.text = value!,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Détails sur la maladie...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _medecinController,
                decoration: const InputDecoration(
                  labelText: 'Médecin traitant',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _telMedecinController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone du médecin',
                ),
              ),
              const SizedBox(height: 12),
              const Text('Traitements', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _traitements.map((t) => Chip(
                  label: Text(t),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => setState(() => _traitements.remove(t)),
                )).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _traitementController,
                      decoration: const InputDecoration(
                        labelText: 'Ajouter un traitement',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_traitementController.text.isNotEmpty) {
                        setState(() => _traitements.add(_traitementController.text));
                        _traitementController.clear();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveMaladie();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A86B),
            ),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showAddMesureDialog(MaladieChronique maladie) {
    final _valeurController = TextEditingController();
    final _notesController = TextEditingController();
    String _typeMesure = 'glycemie';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une mesure'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _typeMesure,
              decoration: const InputDecoration(labelText: 'Type de mesure'),
              items: const [
                DropdownMenuItem(value: 'glycemie', child: Text('Glycémie (g/L)')),
                DropdownMenuItem(value: 'tension', child: Text('Tension (mmHg)')),
                DropdownMenuItem(value: 'poids', child: Text('Poids (kg)')),
                DropdownMenuItem(value: 'temperature', child: Text('Température (°C)')),
              ],
              onChanged: (value) => _typeMesure = value!,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valeurController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Valeur',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
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
              final mesure = MesureVitale(
                id: _uuid.v4(),
                date: DateTime.now(),
                type: _typeMesure,
                valeur: double.tryParse(_valeurController.text) ?? 0,
                notes: _notesController.text,
              );
              _addMesure(maladie, mesure);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A86B),
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _saveMaladie() {
    final maladie = MaladieChronique(
      id: _uuid.v4(),
      nom: _nomController.text,
      type: _typeController.text,
      description: _descriptionController.text,
      dateDiagnostic: DateTime.now(),
      mesures: [],
      traitements: List.from(_traitements),
      medecinTraitant: _medecinController.text,
      telephoneMedecin: _telMedecinController.text,
    );
    _maladiesBox.put(maladie.id, maladie);
    _clearForm();
  }

  void _addMesure(MaladieChronique maladie, MesureVitale mesure) {
    final updatedMesures = List<MesureVitale>.from(maladie.mesures);
    updatedMesures.add(mesure);
    
    final updatedMaladie = MaladieChronique(
      id: maladie.id,
      nom: maladie.nom,
      type: maladie.type,
      description: maladie.description,
      dateDiagnostic: maladie.dateDiagnostic,
      mesures: updatedMesures,
      traitements: maladie.traitements,
      medecinTraitant: maladie.medecinTraitant,
      telephoneMedecin: maladie.telephoneMedecin,
    );
    
    _maladiesBox.put(maladie.id, updatedMaladie);
  }

  void _deleteMaladie(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette maladie ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              _maladiesBox.delete(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _nomController.clear();
    _typeController.clear();
    _descriptionController.clear();
    _medecinController.clear();
    _telMedecinController.clear();
    _traitements.clear();
    _traitementController.clear();
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'diabete':
        return Icons.bloodtype;
      case 'hypertension':
        return Icons.favorite;
      case 'asthme':
        return Icons.air;
      case 'cardiaque':
        return Icons.heart_broken;
      case 'rein':
        return Icons.water_drop;
      default:
        return Icons.medical_services;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'diabete':
        return Colors.blue;
      case 'hypertension':
        return Colors.red;
      case 'asthme':
        return Colors.orange;
      case 'cardiaque':
        return Colors.pink;
      case 'rein':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getMesureIcon(String type) {
    switch (type) {
      case 'glycemie':
        return Icons.bloodtype;
      case 'tension':
        return Icons.favorite;
      case 'poids':
        return Icons.monitor_weight;
      case 'temperature':
        return Icons.thermostat;
      default:
        return Icons.straighten;
    }
  }
}
