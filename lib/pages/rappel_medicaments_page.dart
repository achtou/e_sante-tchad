import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/medicament_model.dart';
import '../utils/colors.dart';
import '../services/medicament_notification_service.dart';
import 'medicament_module/family_profiles_page.dart';

class RappelMedicamentsPage extends StatefulWidget {
  const RappelMedicamentsPage({super.key});

  @override
  State<RappelMedicamentsPage> createState() => _RappelMedicamentsPageState();
}

class _RappelMedicamentsPageState extends State<RappelMedicamentsPage> with TickerProviderStateMixin {
  final _uuid = const Uuid();
  late Box<Medicament> _medicamentsBox;
  late Box<ProfilFamille> _profilsBox;
  final MedicamentNotificationService _notificationService = MedicamentNotificationService();
  String? _selectedProfilId;
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  late AnimationController _controller;
  Map<int, Animation<double>> _cardAnimations = {};

  @override
  void initState() {
    super.initState();
    _medicamentsBox = Hive.box<Medicament>('medicaments');
    _profilsBox = Hive.box<ProfilFamille>('profils_famille');
    _selectedProfilId = _profilsBox.values.first.id;
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    
    _replanifierToutesNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant RappelMedicamentsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _replanifierToutesNotifications() async {
    for (final medicament in _medicamentsBox.values) {
      await _notificationService.planifierNotificationsMedicament(medicament);
    }
  }

  Future<void> _selectProfil() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FamilyProfilesPage(selectedProfilId: _selectedProfilId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(animation),
            child: child,
          );
        },
      ),
    );
    if (result != null && result is ProfilFamille) {
      setState(() {
        _selectedProfilId = result.id;
      });
      _controller.reset();
      _controller.forward();
    }
  }

  Widget _buildProfilSelector() {
    final profil = _profilsBox.get(_selectedProfilId);
    if (profil == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        onTap: _selectProfil,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF00A86B).withOpacity(0.1),
                backgroundImage: profil.photo != null ? NetworkImage(profil.photo!) : null,
                child: profil.photo == null ? const Icon(Icons.person, color: Color(0xFF00A86B), size: 28) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profil.nom,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profil.relation,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A86B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00A86B), size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.8, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Icon(
                  Icons.medication_outlined,
                  size: 100,
                  color: Colors.grey[300],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun médicament enregistré',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Appuyez sur + pour ajouter votre premier médicament',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.9, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: ElevatedButton.icon(
                  onPressed: () => _showMedicamentDialog(),
                  icon: const Icon(Icons.add, size: 24),
                  label: const Text('Ajouter un médicament', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF00A86B).withOpacity(0.4),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicamentCard(Medicament medicament, int index) {
    final isLowStock = medicament.stockActuel <= medicament.stockAlerte;
    bool isPressed = false;
    
    final animation = _cardAnimations.putIfAbsent(
      index,
      () => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutBack),
        ),
      ),
    );

    return StatefulBuilder(
      builder: (context, setState) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 40 * (1 - animation.value)),
              child: Opacity(
                opacity: animation.value,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => isPressed = true),
                  onTapUp: (_) => setState(() => isPressed = false),
                  onTapCancel: () => setState(() => isPressed = false),
                  child: AnimatedScale(
                    scale: isPressed ? 0.98 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Color(int.parse(medicament.couleur.replaceAll('#', '0xFF'))).withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: Color(int.parse(medicament.couleur.replaceAll('#', '0xFF'))).withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Color(int.parse(medicament.couleur.replaceAll('#', '0xFF'))).withOpacity(0.12),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(medicament.couleur.replaceAll('#', '0xFF'))),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(int.parse(medicament.couleur.replaceAll('#', '0xFF'))).withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _getFormeIcon(medicament.forme),
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medicament.nom,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${medicament.forme} • ${medicament.dosage}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isLowStock)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Stock bas',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStockIndicator(medicament),
                                ),
                                const SizedBox(width: 18),
                                _buildStockActions(medicament),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prise(s)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[700],
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: medicament.heuresPrise.map((heure) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00A86B).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: const Color(0xFF00A86B).withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.access_time_rounded, color: Color(0xFF00A86B), size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            heure,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF00A86B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showMedicamentDialog(medicament: medicament),
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                    label: const Text('Modifier', style: TextStyle(fontSize: 15)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF00A86B),
                                      side: const BorderSide(color: Color(0xFF00A86B), width: 1.5),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _deleteMedicament(medicament),
                                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                    label: const Text('Supprimer', style: TextStyle(fontSize: 15)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red[600],
                                      side: BorderSide(color: Colors.red[600]!, width: 1.5),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
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
              'Stock: ${medicament.stockActuel} / ${medicament.stockInitial}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                color: percentage < 0.2 ? Colors.red : const Color(0xFF00A86B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage < 0.2 ? Colors.red : const Color(0xFF00A86B),
            ),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStockActions(Medicament medicament) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red, size: 28),
            onPressed: () => _updateStock(medicament, -1),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF00A86B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF00A86B), size: 28),
            onPressed: () => _updateStock(medicament, 1),
          ),
        ),
      ],
    );
  }

  IconData _getFormeIcon(String forme) {
    switch (forme.toLowerCase()) {
      case 'comprimé':
        return Icons.medication_rounded;
      case 'sirop':
        return Icons.water_drop_rounded;
      case 'injection':
        return Icons.vaccines_rounded;
      case 'pommade':
        return Icons.healing_rounded;
      case 'gouttes':
        return Icons.opacity_rounded;
      default:
        return Icons.medication_rounded;
    }
  }

  void _updateStock(Medicament medicament, int delta) {
    final newStock = medicament.stockActuel + delta;
    if (newStock >= 0) {
      setState(() {
        medicament.stockActuel = newStock;
        medicament.save();
      });
    }
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
    String? profilId = medicament?.profilId ?? _selectedProfilId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isEditing ? 'Modifier le médicament' : 'Ajouter un médicament', style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: profilId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: _profilsBox.values.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Text('${p.nom} (${p.relation})'),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => profilId = value),
                ),
                const SizedBox(height: 20),
                Text('Nom du médicament', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 8),
                TextField(
                  controller: nomController,
                  decoration: InputDecoration(
                    hintText: 'Ex: Paracétamol',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Forme et dosage', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: forme,
                  decoration: InputDecoration(
                    labelText: 'Forme',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  decoration: InputDecoration(
                    labelText: 'Dosage',
                    hintText: 'Ex: 500mg',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Stock', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stockActuelController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Stock actuel',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: stockInitialController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Stock initial',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stockAlerteController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Seuil d\'alerte',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Heures de prise', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: heuresPrise.map((heure) {
                    return Chip(
                      label: Text(heure, style: const TextStyle(fontWeight: FontWeight.w600)),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setDialogState(() {
                          heuresPrise.remove(heure);
                        });
                      },
                      backgroundColor: const Color(0xFF00A86B).withOpacity(0.12),
                      side: const BorderSide(color: Color(0xFF00A86B), width: 1.2),
                      labelStyle: const TextStyle(color: Color(0xFF00A86B)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(primary: Color(0xFF00A86B)),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      final heureFormatee = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      setDialogState(() {
                        if (!heuresPrise.contains(heureFormatee)) {
                          heuresPrise.add(heureFormatee);
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Ajouter une heure'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B).withOpacity(0.1),
                    foregroundColor: const Color(0xFF00A86B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomController.text.isNotEmpty) {
                  final newMedicament = Medicament(
                    id: isEditing ? medicament!.id : _uuid.v4(),
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
                    photoOrdonnance: null,
                    profilId: profilId,
                  );

                  if (isEditing) {
                    medicament!.nom = newMedicament.nom;
                    medicament.forme = newMedicament.forme;
                    medicament.dosage = newMedicament.dosage;
                    medicament.stockActuel = newMedicament.stockActuel;
                    medicament.stockInitial = newMedicament.stockInitial;
                    medicament.stockAlerte = newMedicament.stockAlerte;
                    medicament.heuresPrise = newMedicament.heuresPrise;
                    medicament.profilId = profilId;
                    medicament.save();
                    await _notificationService.planifierNotificationsMedicament(medicament);
                  } else {
                    _medicamentsBox.put(newMedicament.id, newMedicament);
                    await _notificationService.planifierNotificationsMedicament(newMedicament);
                  }

                  Navigator.pop(context);
                  _controller.reset();
                  _controller.forward();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A86B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              child: Text(isEditing ? 'Enregistrer' : 'Ajouter', style: const TextStyle(fontWeight: FontWeight.bold)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Supprimer ${medicament.nom} ?', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await _notificationService.annulerNotificationsMedicament(medicament.id);
              _medicamentsBox.delete(medicament.id);
              Navigator.pop(context);
              _controller.reset();
              _controller.forward();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Supprimer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rappel de Médicaments',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.group_rounded, color: Colors.white, size: 26),
              onPressed: () => Navigator.pushNamed(context, '/medicaments/family'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              onPressed: () => _showMedicamentDialog(),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        color: const Color(0xFF00A86B),
        backgroundColor: Colors.white,
        strokeWidth: 3,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 800));
          _controller.reset();
          _controller.forward();
        },
        child: Column(
          children: [
            _buildProfilSelector(),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _medicamentsBox.listenable(),
                builder: (context, Box<Medicament> box, _) {
                  final medicaments = box.values.where((m) => m.profilId == _selectedProfilId).toList();

                  if (medicaments.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: medicaments.length,
                    itemBuilder: (context, index) {
                      return _buildMedicamentCard(medicaments[index], index);
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
}
