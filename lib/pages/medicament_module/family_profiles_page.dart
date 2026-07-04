import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/medicament_module/medicament_module.dart';
import '../../utils/colors.dart';

class FamilyProfilesPage extends StatefulWidget {
  const FamilyProfilesPage({super.key});

  @override
  State<FamilyProfilesPage> createState() => _FamilyProfilesPageState();
}

class _FamilyProfilesPageState extends State<FamilyProfilesPage> {
  final _uuid = const Uuid();
  final ImagePicker _imagePicker = ImagePicker();
  List<ProfilFamille> _profils = [];

  @override
  void initState() {
    super.initState();
    _profils = [
      ProfilFamille(
        id: _uuid.v4(),
        nom: 'Moi',
        relation: 'Moi',
        dateNaissance: DateTime(1995, 1, 1),
      ),
    ];
  }

  Future<void> _pickImage(ProfilFamille profil) async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        final index = _profils.indexWhere((p) => p.id == profil.id);
        if (index != -1) {
          _profils[index] = ProfilFamille(
            id: profil.id,
            nom: profil.nom,
            relation: profil.relation,
            photo: image.path,
            dateNaissance: profil.dateNaissance,
            medicamentsIds: profil.medicamentsIds,
          );
        }
      });
    }
  }

  void _ajouterProfil() {
    showDialog(
      context: context,
      builder: (context) => _AddProfilDialog(
        onAdd: (nom, relation, dateNaissance) {
          setState(() {
            _profils.add(ProfilFamille(
              id: _uuid.v4(),
              nom: nom,
              relation: relation,
              dateNaissance: dateNaissance,
            ));
          });
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
    setState(() {
      _profils.removeWhere((p) => p.id == profil.id);
    });
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _profils.length,
        itemBuilder: (context, index) {
          final profil = _profils[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
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
              title: Text(profil.nom),
              subtitle: Text('${profil.relation} • ${profil.medicamentsIds.length} médicaments'),
              trailing: profil.relation != 'Moi'
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _supprimerProfil(profil),
                    )
                  : null,
            ),
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
