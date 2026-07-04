import 'package:hive/hive.dart';
part 'dossier_model.g.dart';

@HiveType(typeId: 2)
class DossierMedical extends HiveObject {

  @HiveField(0)
  String id;

  // IDENTITÉ
  @HiveField(1)
  String nom;

  @HiveField(2)
  String prenom;

  @HiveField(3)
  DateTime dateNaissance;

  @HiveField(4)
  String sexe; // 'Homme' ou 'Femme'

  @HiveField(5)
  String telephone;

  @HiveField(6)
  String ville;

  @HiveField(7)
  String? photoPath;

  // MÉDICAL
  @HiveField(8)
  String groupeSanguin;
  // A+, A-, B+, B-, AB+, AB-, O+, O-

  @HiveField(9)
  double poids; // kg

  @HiveField(10)
  double taille; // cm

  @HiveField(11)
  List<String> allergies;

  @HiveField(12)
  List<String> maladiesChroniques;
  // Diabète, Hypertension, 
  // Drépanocytose, Asthme,
  // VIH, Tuberculose, Épilepsie

  @HiveField(13)
  String traitementsEnCours;

  // CONTACT URGENCE
  @HiveField(14)
  String nomContactUrgence;

  @HiveField(15)
  String telContactUrgence;

  // VACCINATIONS
  @HiveField(16)
  List<String> vaccinsEffectues;

  // CONSULTATIONS
  @HiveField(17)
  List<String> consultationsJson;
  // stockées en JSON string

  @HiveField(18)
  DateTime dateCreation;

  DossierMedical({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    this.sexe = 'Homme',
    this.telephone = '',
    this.ville = '',
    this.photoPath,
    this.groupeSanguin = 'O+',
    this.poids = 0,
    this.taille = 0,
    this.allergies = const [],
    this.maladiesChroniques = const [],
    this.traitementsEnCours = '',
    this.nomContactUrgence = '',
    this.telContactUrgence = '',
    this.vaccinsEffectues = const [],
    this.consultationsJson = const [],
    required this.dateCreation,
  });
}
