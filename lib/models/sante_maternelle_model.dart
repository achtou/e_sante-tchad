import 'package:hive/hive.dart';

part 'sante_maternelle_model.g.dart';

@HiveType(typeId: 10)
class Grossesse extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime dateDebut;

  @HiveField(2)
  DateTime dateAccouchementPrevue;

  @HiveField(3)
  DateTime? dateAccouchementReelle;

  @HiveField(4)
  int nombreEnfantsPrecedents;

  @HiveField(5)
  String groupeSanguin;

  @HiveField(6)
  String? facteursRisques;

  @HiveField(7)
  bool estTerminee;

  @HiveField(8)
  DateTime dateCreation;

  Grossesse({
    required this.id,
    required this.dateDebut,
    required this.dateAccouchementPrevue,
    this.dateAccouchementReelle,
    required this.nombreEnfantsPrecedents,
    required this.groupeSanguin,
    this.facteursRisques,
    this.estTerminee = false,
    required this.dateCreation,
  });

  int get semainesGrossesse {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(dateDebut);
    return (difference.inDays / 7).floor();
  }

  int get joursRestants {
    final maintenant = DateTime.now();
    return dateAccouchementPrevue.difference(maintenant).inDays;
  }

  String get trimestre {
    final semaines = semainesGrossesse;
    if (semaines <= 13) return '1er trimestre';
    if (semaines <= 26) return '2ème trimestre';
    return '3ème trimestre';
  }
}

@HiveType(typeId: 11)
class VisitePrenatale extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String grossesseId;

  @HiveField(2)
  DateTime dateVisite;

  @HiveField(3)
  double poids;

  @HiveField(4)
  double tensionArterielle;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  bool examensEffectues;

  @HiveField(7)
  String? examensDetails;

  @HiveField(8)
  DateTime dateCreation;

  VisitePrenatale({
    required this.id,
    required this.grossesseId,
    required this.dateVisite,
    required this.poids,
    required this.tensionArterielle,
    this.notes,
    this.examensEffectues = false,
    this.examensDetails,
    required this.dateCreation,
  });
}

@HiveType(typeId: 12)
class Enfant extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? grossesseId;

  @HiveField(2)
  String nom;

  @HiveField(3)
  DateTime dateNaissance;

  @HiveField(4)
  double poidsNaissance;

  @HiveField(5)
  double tailleNaissance;

  @HiveField(6)
  String sexe;

  @HiveField(7)
  String groupeSanguin;

  @HiveField(8)
  DateTime dateCreation;

  Enfant({
    required this.id,
    this.grossesseId,
    required this.nom,
    required this.dateNaissance,
    required this.poidsNaissance,
    required this.tailleNaissance,
    required this.sexe,
    required this.groupeSanguin,
    required this.dateCreation,
  });

  int get ageMois {
    final maintenant = DateTime.now();
    final difference = maintenant.difference(dateNaissance);
    return (difference.inDays / 30).floor();
  }

  String get ageText {
    final mois = ageMois;
    if (mois < 12) {
      return '$mois mois';
    }
    final annees = mois ~/ 12;
    final moisRestants = mois % 12;
    if (moisRestants == 0) {
      return '$annees an${annees > 1 ? 's' : ''}';
    }
    return '$annees an${annees > 1 ? 's' : ''} et $moisRestants mois';
  }
}

@HiveType(typeId: 13)
class Vaccination extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String enfantId;

  @HiveField(2)
  String nomVaccin;

  @HiveField(3)
  DateTime datePrevue;

  @HiveField(4)
  DateTime? dateAdministree;

  @HiveField(5)
  bool estAdministre;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  DateTime dateCreation;

  Vaccination({
    required this.id,
    required this.enfantId,
    required this.nomVaccin,
    required this.datePrevue,
    this.dateAdministree,
    this.estAdministre = false,
    this.notes,
    required this.dateCreation,
  });

  bool get estEnRetard {
    if (estAdministre) return false;
    return DateTime.now().isAfter(datePrevue);
  }

  bool get estAProche {
    if (estAdministre) return false;
    final difference = datePrevue.difference(DateTime.now()).inDays;
    return difference >= 0 && difference <= 7;
  }
}

@HiveType(typeId: 14)
class SuiviCroissance extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String enfantId;

  @HiveField(2)
  DateTime dateMesure;

  @HiveField(3)
  double poids;

  @HiveField(4)
  double taille;

  @HiveField(5)
  double? perimetreCranien;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  DateTime dateCreation;

  SuiviCroissance({
    required this.id,
    required this.enfantId,
    required this.dateMesure,
    required this.poids,
    required this.taille,
    this.perimetreCranien,
    this.notes,
    required this.dateCreation,
  });
}
