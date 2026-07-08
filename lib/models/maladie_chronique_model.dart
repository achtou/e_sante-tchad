import 'package:hive/hive.dart';

part 'maladie_chronique_model.g.dart';

@HiveType(typeId: 17)
class MaladieChronique extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nom;

  @HiveField(2)
  String type;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime dateDiagnostic;

  @HiveField(5)
  List<MesureVitale> mesures;

  @HiveField(6)
  List<String> traitements;

  @HiveField(7)
  String medecinTraitant;

  @HiveField(8)
  String telephoneMedecin;

  MaladieChronique({
    required this.id,
    required this.nom,
    required this.type,
    required this.description,
    required this.dateDiagnostic,
    required this.mesures,
    required this.traitements,
    required this.medecinTraitant,
    required this.telephoneMedecin,
  });
}

@HiveType(typeId: 18)
class MesureVitale {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String type;

  @HiveField(3)
  double valeur;

  @HiveField(4)
  String notes;

  MesureVitale({
    required this.id,
    required this.date,
    required this.type,
    required this.valeur,
    required this.notes,
  });
}
