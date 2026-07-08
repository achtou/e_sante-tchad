import 'package:hive/hive.dart';
part 'medicament_model.g.dart';

@HiveType(typeId: 7)
class ProfilFamille extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nom;

  @HiveField(2)
  String relation; // 'Moi', 'Enfant', 'Papa', 'Maman enceinte', 'Autre'

  @HiveField(3)
  String? photo;

  @HiveField(4)
  DateTime dateNaissance;

  ProfilFamille({
    required this.id,
    required this.nom,
    required this.relation,
    this.photo,
    required this.dateNaissance,
  });
}

@HiveType(typeId: 5)
class Medicament extends HiveObject {

  @HiveField(0)
  String id;

  // INFORMATIONS DE BASE
  @HiveField(1)
  String nom;
  // Suggestions : Paracétamol, Amoxicilline,
  // Artemether, Métronidazole, Cotrimoxazole,
  // Fer + Acide folique, Zinc, Ibuprofène,
  // Amoxicilline, Ciprofloxacine

  @HiveField(2)
  String forme;
  // 'Comprimé' | 'Sirop' | 
  // 'Injection' | 'Pommade' | 'Gouttes'

  @HiveField(3)
  String dosage;
  // ex: '500mg', '250mg/5ml'

  @HiveField(4)
  String couleur;
  // Pour identifier visuellement

  // STOCK
  @HiveField(5)
  int stockActuel;
  // Nombre de comprimés/ml restants

  @HiveField(6)
  int stockInitial;
  // Stock au départ

  @HiveField(7)
  int stockAlerte;
  // Seuil d'alerte (ex: 5 comprimés)

  // POSOLOGIE
  @HiveField(8)
  List<String> heuresPrise;
  // ['08:00', '14:00', '20:00']

  @HiveField(9)
  List<bool> joursActifs;
  // 7 jours : [lun, mar, mer, jeu, ven, sam, dim]

  @HiveField(10)
  int dureeTreatement;
  // Nombre de jours total

  @HiveField(11)
  DateTime dateDebut;

  @HiveField(12)
  DateTime dateFin;

  // RAPPELS
  @HiveField(13)
  bool rappelActif;

  @HiveField(14)
  String notesPharmacien;
  // Instructions spéciales

  @HiveField(15)
  String prescritPar;
  // Nom du médecin

  @HiveField(16)
  String hopital;

  // HISTORIQUE PRISES
  @HiveField(17)
  List<String> prisesJson;
  // JSON des prises : date + statut

  @HiveField(18)
  DateTime dateCreation;

  // ORDONNANCE
  @HiveField(19)
  String? photoOrdonnance;

  @HiveField(20)
  String? profilId;

  Medicament({
    required this.id,
    required this.nom,
    this.forme = 'Comprimé',
    this.dosage = '',
    this.couleur = '#00C853',
    this.stockActuel = 0,
    this.stockInitial = 0,
    this.stockAlerte = 5,
    this.heuresPrise = const ['08:00'],
    this.joursActifs = const [
      true, true, true,
      true, true, true, true
    ],
    this.dureeTreatement = 7,
    required this.dateDebut,
    required this.dateFin,
    this.rappelActif = true,
    this.notesPharmacien = '',
    this.prescritPar = '',
    this.hopital = '',
    this.prisesJson = const [],
    required this.dateCreation,
    this.photoOrdonnance,
    this.profilId,
  });
}

@HiveType(typeId: 6)
class PriseMedicament extends HiveObject {
  @HiveField(0)
  String medicamentId;

  @HiveField(1)
  DateTime dateHeure;

  @HiveField(2)
  String statut;
  // 'pris' | 'oublie' | 'reporte'

  @HiveField(3)
  String? notes;

  PriseMedicament({
    required this.medicamentId,
    required this.dateHeure,
    required this.statut,
    this.notes,
  });
}
