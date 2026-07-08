import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/medicament_model.dart';
import '../../utils/colors.dart';

class FamilyProfilesPage extends StatefulWidget {
  final String? selectedProfilId;
  const FamilyProfilesPage({super.key, this.selectedProfilId});

  @override
  State<FamilyProfilesPage> createState() => _FamilyProfilesPageState();
}

class _FamilyProfilesPageState extends State<FamilyProfilesPage> {
  final _uuid = const Uuid();
  final ImagePicker _imagePicker = ImagePicker();
  late Box<ProfilFamille> _profilsBox;
  late Box<Medicament> _medicamentsBox;

  @override
  void initState() {
    super.initState();
    _profilsBox = Hive.box<ProfilFamille>('profils_famille');
    _medicamentsBox = Hive.box<Medicament>('medicaments');
  }

  Future<void> _pickImage(ProfilFamille profil) async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profil.photo = image.path;
      profil.save();
    }
  }

  int _countMedicamentsForProfil(String profilId) {
    return _medicamentsBox.values.where((m) => m.profilId == profilId).length;
  }

  void _ajouterProfil() {
    showDialog(
      context: context,
      builder: (context) => _AddProfilDialog(
        onAdd: (nom, relation, dateNaissance) {
          final profil = ProfilFamille(
            id: _uuid.v4(),
            nom: nom,
            relation: relation,
            dateNaissance: dateNaissance,
          );
          _profilsBox.put(profil.id, profil);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _modifierProfil(ProfilFamille profil) {
    showDialog(
      context: context,
      builder: (context) => _EditProfilDialog(
        profil: profil,
        onEdit: (nom, relation, dateNaissance) {
          profil.nom = nom;
          profil.relation = relation;
          profil.dateNaissance = dateNaissance;
          profil.save();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _supprimerProfil(ProfilFamille profil) {
    if (profil.relation == 'Moi') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de supprimer votre profil')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le profil'),
        content: Text('Voulez-vous vraiment supprimer ${profil.nom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              _profilsBox.delete(profil.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        title: const Text('Profils famille'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _ajouterProfil,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _profilsBox.listenable(),
        builder: (context, Box<ProfilFamille> box, _) {
          final profils = box.values.toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profils.length,
            itemBuilder: (context, index) {
              final profil = profils[index];
              final isSelected = widget.selectedProfilId == profil.id;
              final nbMedicaments = _countMedicamentsForProfil(profil.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: isSelected ? const Color(0xFF00A86B).withOpacity(0.1) : null,
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () => _pickImage(profil),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: profil.photo != null ? NetworkImage(profil.photo!) : null,
                      child: profil.photo == null
                          ? Icon(Icons.person, color: Colors.grey[400], size: 32)
                          : null,
                    ),
                  ),
                  title: Text(profil.nom, style: isSelected ? const TextStyle(fontWeight: FontWeight.bold) : null),
                  subtitle: Text('${profil.relation} • $nbMedicaments médicaments'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF00A86B)),
                        onPressed: () => _modifierProfil(profil),
                      ),
                      if (profil.relation != 'Moi')
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _supprimerProfil(profil),
                        ),
                    ],
                  ),
                  onTap: widget.selectedProfilId != null
                      ? () => Navigator.pop(context, profil)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AddProfilDialog extends StatefulWidget {
  final Function(String nom, String relation, DateTime dateNaissance) onAdd;

  const _AddProfilDialog({required this.onAdd});

  @override
  State<_AddProfilDialog> createState() => _AddProfilDialogState();
}

class _AddProfilDialogState extends State<_AddProfilDialog> {
  final _nomController = TextEditingController();
  String _relation = 'Enfant';
  DateTime _dateNaissance = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un profil'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nomController,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _relation,
            decoration: const InputDecoration(labelText: 'Relation'),
            items: const [
              DropdownMenuItem(value: 'Enfant', child: Text('Enfant')),
              DropdownMenuItem(value: 'Papa', child: Text('Papa')),
              DropdownMenuItem(value: 'Maman', child: Text('Maman')),
              DropdownMenuItem(value: 'Maman enceinte', child: Text('Maman enceinte')),
              DropdownMenuItem(value: 'Autre', child: Text('Autre')),
            ],
            onChanged: (value) => setState(() => _relation = value!),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Date de naissance'),
            subtitle: Text('${_dateNaissance.day}/${_dateNaissance.month}/${_dateNaissance.year}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dateNaissance,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _dateNaissance = date);
              }
            },
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
            if (_nomController.text.isNotEmpty) {
              widget.onAdd(_nomController.text, _relation, _dateNaissance);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A86B)),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

class _EditProfilDialog extends StatefulWidget {
  final ProfilFamille profil;
  final Function(String nom, String relation, DateTime dateNaissance) onEdit;

  const _EditProfilDialog({required this.profil, required this.onEdit});

  @override
  State<_EditProfilDialog> createState() => _EditProfilDialogState();
}

class _EditProfilDialogState extends State<_EditProfilDialog> {
  final _nomController = TextEditingController();
  String _relation = 'Enfant';
  DateTime _dateNaissance = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nomController.text = widget.profil.nom;
    _relation = widget.profil.relation;
    _dateNaissance = widget.profil.dateNaissance;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le profil'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nomController,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _relation,
            decoration: const InputDecoration(labelText: 'Relation'),
            items: const [
              DropdownMenuItem(value: 'Enfant', child: Text('Enfant')),
              DropdownMenuItem(value: 'Papa', child: Text('Papa')),
              DropdownMenuItem(value: 'Maman', child: Text('Maman')),
              DropdownMenuItem(value: 'Maman enceinte', child: Text('Maman enceinte')),
              DropdownMenuItem(value: 'Autre', child: Text('Autre')),
            ],
            onChanged: (value) => setState(() => _relation = value!),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Date de naissance'),
            subtitle: Text('${_dateNaissance.day}/${_dateNaissance.month}/${_dateNaissance.year}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dateNaissance,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _dateNaissance = date);
              }
            },
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
            if (_nomController.text.isNotEmpty) {
              widget.onEdit(_nomController.text, _relation, _dateNaissance);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A86B)),
          child: const Text('Sauvegarder'),
        ),
      ],
    );
  }
}
