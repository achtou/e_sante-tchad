import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/medicament_module/medicament_module.dart';
import '../../utils/colors.dart';

class AddMedsPage extends StatefulWidget {
  final String? profilId;
  const AddMedsPage({super.key, this.profilId});

  @override
  State<AddMedsPage> createState() => _AddMedsPageState();
}

class _AddMedsPageState extends State<AddMedsPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers
  final _nomController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesMedecinController = TextEditingController();
  final _prescritParController = TextEditingController();

  // Variables
  String? _photoBoite;
  String _forme = 'comprimé';
  int _frequenceParJour = 1;
  List<HorairePrise> _horairesPrise = [];
  int _dureeJours = 7;
  String _profilBeneficiaireId = '';
  int _stockInitial = 20;
  int _seuilAlerte = 5;

  @override
  void initState() {
    super.initState();
    _profilBeneficiaireId = widget.profilId ?? '';
    _horairesPrise = [
      HorairePrise(id: _uuid.v4(), heure: '08:00'),
    ];
  }

  @override
  void dispose() {
    _nomController.dispose();
    _dosageController.dispose();
    _notesMedecinController.dispose();
    _prescritParController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoBoite = image.path;
      });
    }
  }

  void _ajouterHoraire() {
    setState(() {
      _horairesPrise.add(HorairePrise(id: _uuid.v4(), heure: '12:00'));
    });
  }

  void _supprimerHoraire(int index) {
    if (_horairesPrise.length > 1) {
      setState(() {
        _horairesPrise.removeAt(index);
      });
    }
  }

  void _enregistrerMedicament() {
    if (_formKey.currentState!.validate()) {
      final medicament = MedicamentModule(
        id: _uuid.v4(),
        nom: _nomController.text,
        photoBoite: _photoBoite,
        forme: _forme,
        dosage: _dosageController.text,
        frequenceParJour: _frequenceParJour,
        horairesPrise: _horairesPrise,
        dureeJours: _dureeJours,
        profilBeneficiaireId: _profilBeneficiaireId,
        notesMedecin: _notesMedecinController.text,
        prescritPar: _prescritParController.text,
        dateDebut: DateTime.now(),
        dateFin: DateTime.now().add(Duration(days: _dureeJours)),
        stock: StockTracker(
          id: _uuid.v4(),
          medicamentId: _uuid.v4(),
          stockInitial: _stockInitial,
          stockActuel: _stockInitial,
          seuilAlerte: _seuilAlerte,
        ),
      );

      Navigator.pop(context, medicament);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        title: const Text('Ajouter un médicament'),
        actions: [
          TextButton(
            onPressed: _enregistrerMedicament,
            child: const Text(
              'Enregistrer',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo de la boîte (obligatoire pour accessibilité)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Photo de la boîte *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Obligatoire pour les analphabètes',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _photoBoite != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _photoBoite!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Appuyer pour ajouter', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Nom du médicament
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nom du médicament *',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        hintText: 'Ex: Paracétamol',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Champ obligatoire' : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Forme et dosage
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Forme et dosage',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _forme,
                      decoration: const InputDecoration(
                        labelText: 'Forme',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'comprimé', child: Text('Comprimé')),
                        DropdownMenuItem(value: 'sirop', child: Text('Sirop')),
                        DropdownMenuItem(value: 'injection', child: Text('Injection')),
                        DropdownMenuItem(value: 'pommade', child: Text('Pommade')),
                        DropdownMenuItem(value: 'gouttes', child: Text('Gouttes')),
                      ],
                      onChanged: (value) => setState(() => _forme = value!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Dosage (ex: 500mg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Fréquence et durée
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fréquence et durée',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Fréquence: '),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: _frequenceParJour,
                          items: List.generate(4, (i) => i + 1)
                              .map((freq) => DropdownMenuItem(
                                    value: freq,
                                    child: Text('$freq fois/jour'),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _frequenceParJour = value!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Durée: '),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: _dureeJours,
                          items: [3, 5, 7, 10, 14, 21, 30]
                              .map((jours) => DropdownMenuItem(
                                    value: jours,
                                    child: Text('$jours jours'),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _dureeJours = value!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Horaires de prise
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Heures de prise',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Color(0xFF00A86B)),
                          onPressed: _ajouterHoraire,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_horairesPrise.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TimePickerDialog(
                                initialTime: TimeOfDay(
                                  hour: int.parse(_horairesPrise[index].heure.split(':')[0]),
                                  minute: int.parse(_horairesPrise[index].heure.split(':')[1]),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _supprimerHoraire(index),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Stock
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stock',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _stockInitial.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Stock initial',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => _stockInitial = int.tryParse(value) ?? 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: _seuilAlerte.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Seuil alerte',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => _seuilAlerte = int.tryParse(value) ?? 5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes médecin
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations médicales',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _prescritParController,
                      decoration: const InputDecoration(
                        labelText: 'Prescrit par',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesMedecinController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes du médecin',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
