import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/medicament_model.dart';
import '../utils/colors.dart';

class RappelMedicamentsPage extends StatefulWidget {
  const RappelMedicamentsPage({super.key});

  @override
  State<RappelMedicamentsPage> createState() => _RappelMedicamentsPageState();
}

class _RappelMedicamentsPageState extends State<RappelMedicamentsPage> {
  final _uuid = const Uuid();
  late Box<Medicament> _medicamentsBox;
  
  @override
  void initState() {
    super.initState();
    _medicamentsBox = Hive.box<Medicament>('medicaments');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rappel de Médicaments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Suivez vos traitements',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/medicaments/family'),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/medicaments/add'),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _medicamentsBox.listenable(),
        builder: (context, Box<Medicament> box, _) {
          final medicaments = box.values.toList();
          
          if (medicaments.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicaments.length,
            itemBuilder: (context, index) {
              final medicament = medicaments[index];
              return _buildMedicamentCard(medicament);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun médicament enregistré',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur + pour ajouter votre premier médicament',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/medicaments/add'),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un médicament'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A86B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicamentCard(Medicament medicament) {
    final isLowStock = medicament.stockActuel <= medicament.stockAlerte;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(int.parse(medicament.couleur.replaceAll('#', '0xFF'))).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(int.parse(medicament.couleur.replaceAll('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFormeIcon(medicament.forme),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicament.nom,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${medicament.forme} - ${medicament.dosage}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Stock bas',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Stock info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStockIndicator(medicament),
                ),
                const SizedBox(width: 16),
                _buildStockActions(medicament),
              ],
            ),
          ),
          
          // Posologie
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Posologie',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: medicament.heuresPrise.map((heure) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A86B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00A86B)),
                      ),
                      child: Text(
                        heure,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00A86B),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditMedicamentDialog(medicament),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Modifier'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00A86B),
                      side: const BorderSide(color: Color(0xFF00A86B)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteMedicament(medicament),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Supprimer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStockIndicator(Medicament medicament) {
    final percentage = medicament.stockInitial > 0 
        ? (medicament.stockActuel / medicament.stockInitial) 
        : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Stock: ${medicament.stockActuel}/${medicament.stockInitial}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: percentage < 0.2 ? Colors.red : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage < 0.2 ? Colors.red : const Color(0xFF00A86B),
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStockActions(Medicament medicament) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () => _updateStock(medicament, -1),
          color: Colors.red,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _updateStock(medicament, 1),
          color: const Color(0xFF00A86B),
        ),
      ],
    );
  }

  IconData _getFormeIcon(String forme) {
    switch (forme.toLowerCase()) {
      case 'comprimé':
        return Icons.medication;
      case 'sirop':
        return Icons.water_drop;
      case 'injection':
        return Icons.vaccines;
      case 'pommade':
        return Icons.healing;
      case 'gouttes':
        return Icons.opacity;
      default:
        return Icons.medication;
    }
  }

  void _updateStock(Medicament medicament, int delta) {
    final newStock = medicament.stockActuel + delta;
    if (newStock >= 0) {
      medicament.stockActuel = newStock;
      medicament.save();
    }
  }

  void _showEditMedicamentDialog(Medicament medicament) {
    _showMedicamentDialog(medicament: medicament);
  }

  void _showMedicamentDialog({Medicament? medicament}) {
    final isEditing = medicament != null;
    final nomController = TextEditingController(text: medicament?.nom ?? '');
    final dosageController = TextEditingController(text: medicament?.dosage ?? '');
    final stockActuelController = TextEditingController(text: medicament?.stockActuel.toString() ?? '0');
    final stockInitialController = TextEditingController(text: medicament?.stockInitial.toString() ?? '0');
    final stockAlerteController = TextEditingController(text: medicament?.stockAlerte.toString() ?? '5');
    
    String forme = medicament?.forme ?? 'Comprimé';
    String couleur = medicament?.couleur ?? '#00C853';
    List<String> heuresPrise = medicament?.heuresPrise ?? ['08:00'];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Modifier le médicament' : 'Ajouter un médicament'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du médicament',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: forme,
                  decoration: const InputDecoration(
                    labelText: 'Forme',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Comprimé', child: Text('Comprimé')),
                    DropdownMenuItem(value: 'Sirop', child: Text('Sirop')),
                    DropdownMenuItem(value: 'Injection', child: Text('Injection')),
                    DropdownMenuItem(value: 'Pommade', child: Text('Pommade')),
                    DropdownMenuItem(value: 'Gouttes', child: Text('Gouttes')),
                  ],
                  onChanged: (value) => setDialogState(() => forme = value!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage (ex: 500mg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stockActuelController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stock actuel',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: stockInitialController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stock initial',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockAlerteController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Seuil d\'alerte',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Heures de prise'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: heuresPrise.map((heure) {
                    return Chip(
                      label: Text(heure),
                      onDeleted: () {
                        setDialogState(() {
                          heuresPrise.remove(heure);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setDialogState(() {
                      if (!heuresPrise.contains('12:00')) {
                        heuresPrise.add('12:00');
                      }
                    });
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Ajouter heure'),
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
                final newMedicament = Medicament(
                  id: isEditing ? medicament.id : _uuid.v4(),
                  nom: nomController.text,
                  forme: forme,
                  dosage: dosageController.text,
                  couleur: couleur,
                  stockActuel: int.tryParse(stockActuelController.text) ?? 0,
                  stockInitial: int.tryParse(stockInitialController.text) ?? 0,
                  stockAlerte: int.tryParse(stockAlerteController.text) ?? 5,
                  heuresPrise: heuresPrise,
                  joursActifs: const [true, true, true, true, true, true, true],
                  dureeTreatement: 7,
                  dateDebut: DateTime.now(),
                  dateFin: DateTime.now().add(const Duration(days: 30)),
                  rappelActif: true,
                  notesPharmacien: '',
                  prescritPar: '',
                  hopital: '',
                  prisesJson: const [],
                  dateCreation: DateTime.now(),
                );
                
                if (isEditing) {
                  medicament.nom = newMedicament.nom;
                  medicament.forme = newMedicament.forme;
                  medicament.dosage = newMedicament.dosage;
                  medicament.stockActuel = newMedicament.stockActuel;
                  medicament.stockInitial = newMedicament.stockInitial;
                  medicament.stockAlerte = newMedicament.stockAlerte;
                  medicament.heuresPrise = newMedicament.heuresPrise;
                  medicament.save();
                } else {
                  _medicamentsBox.put(newMedicament.id, newMedicament);
                }
                
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
              ),
              child: Text(isEditing ? 'Modifier' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMedicament(Medicament medicament) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le médicament'),
        content: Text('Voulez-vous vraiment supprimer ${medicament.nom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              _medicamentsBox.delete(medicament.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
