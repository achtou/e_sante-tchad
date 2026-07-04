/// Pitch : “C'est un infirmier numérique dans le téléphone qui gère tous les médicaments et te rappelle de les prendre à temps.”

/// Modèles de données pour le module Médicaments

class ProfilFamille {
  final String id;
  final String nom;
  final String relation; // 'Moi', 'Enfant', 'Papa', 'Maman enceinte', 'Autre'
  final String? photo;
  final DateTime dateNaissance;
  final List<String> medicamentsIds;

  ProfilFamille({
    required this.id,
    required this.nom,
    required this.relation,
    this.photo,
    required this.dateNaissance,
    this.medicamentsIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'relation': relation,
    'photo': photo,
    'dateNaissance': dateNaissance.toIso8601String(),
    'medicamentsIds': medicamentsIds,
  };

  factory ProfilFamille.fromJson(Map<String, dynamic> json) => ProfilFamille(
    id: json['id'],
    nom: json['nom'],
    relation: json['relation'],
    photo: json['photo'],
    dateNaissance: DateTime.parse(json['dateNaissance']),
    medicamentsIds: List<String>.from(json['medicamentsIds'] ?? []),
  );
}

class HorairePrise {
  final String id;
  final String heure; // '08:00', '14:00', '20:00'
  final List<bool> joursActifs; // [lun, mar, mer, jeu, ven, sam, dim]

  HorairePrise({
    required this.id,
    required this.heure,
    this.joursActifs = const [true, true, true, true, true, true, true],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'heure': heure,
    'joursActifs': joursActifs,
  };

  factory HorairePrise.fromJson(Map<String, dynamic> json) => HorairePrise(
    id: json['id'],
    heure: json['heure'],
    joursActifs: List<bool>.from(json['joursActifs'] ?? [true, true, true, true, true, true, true]),
  );
}

class PriseStatut {
  final String id;
  final String medicamentId;
  final String horairePriseId;
  final DateTime datePrevue;
  final DateTime? datePrise;
  final String statut; // 'pris', 'manque', 'reporte', 'en_attente'
  final String? notes;
  final String? actionUtilisateur; // 'j_ai_pris', '+30min', 'ignore'

  PriseStatut({
    required this.id,
    required this.medicamentId,
    required this.horairePriseId,
    required this.datePrevue,
    this.datePrise,
    this.statut = 'en_attente',
    this.notes,
    this.actionUtilisateur,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicamentId': medicamentId,
    'horairePriseId': horairePriseId,
    'datePrevue': datePrevue.toIso8601String(),
    'datePrise': datePrise?.toIso8601String(),
    'statut': statut,
    'notes': notes,
    'actionUtilisateur': actionUtilisateur,
  };

  factory PriseStatut.fromJson(Map<String, dynamic> json) => PriseStatut(
    id: json['id'],
    medicamentId: json['medicamentId'],
    horairePriseId: json['horairePriseId'],
    datePrevue: DateTime.parse(json['datePrevue']),
    datePrise: json['datePrise'] != null ? DateTime.parse(json['datePrise']) : null,
    statut: json['statut'] ?? 'en_attente',
    notes: json['notes'],
    actionUtilisateur: json['actionUtilisateur'],
  );
}

class StockTracker {
  final String id;
  final String medicamentId;
  final int stockInitial;
  final int stockActuel;
  final int seuilAlerte;
  final DateTime dateDernierMaj;

  StockTracker({
    required this.id,
    required this.medicamentId,
    required this.stockInitial,
    required this.stockActuel,
    this.seuilAlerte = 5,
    DateTime? dateDernierMaj,
  }) : dateDernierMaj = dateDernierMaj ?? DateTime.now();

  double get pourcentageRestant => stockInitial > 0 ? (stockActuel / stockInitial) * 100 : 0;
  bool get estStockBas => stockActuel <= seuilAlerte;

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicamentId': medicamentId,
    'stockInitial': stockInitial,
    'stockActuel': stockActuel,
    'seuilAlerte': seuilAlerte,
    'dateDernierMaj': dateDernierMaj.toIso8601String(),
  };

  factory StockTracker.fromJson(Map<String, dynamic> json) => StockTracker(
    id: json['id'],
    medicamentId: json['medicamentId'],
    stockInitial: json['stockInitial'],
    stockActuel: json['stockActuel'],
    seuilAlerte: json['seuilAlerte'] ?? 5,
    dateDernierMaj: DateTime.parse(json['dateDernierMaj']),
  );
}

class RapportObservance {
  final String id;
  final String medicamentId;
  final String profilId;
  final DateTime periodeDebut;
  final DateTime periodeFin;
  final int prisesPrevues;
  final int prisesRealisees;
  final int prisesManquees;
  final double tauxObservance;
  final List<PriseStatut> detailsPrises;

  RapportObservance({
    required this.id,
    required this.medicamentId,
    required this.profilId,
    required this.periodeDebut,
    required this.periodeFin,
    required this.prisesPrevues,
    required this.prisesRealisees,
    required this.prisesManquees,
    required this.tauxObservance,
    required this.detailsPrises,
  });

  String get messageMotivation {
    if (tauxObservance >= 90) return '🌟 Excellent ! Continuez comme ça !';
    if (tauxObservance >= 70) return '👍 Bien ! Vous pouvez faire mieux.';
    if (tauxObservance >= 50) return '⚠️ Attention, essayez d\'être plus régulier.';
    return '❌ Critique ! Consultez votre médecin.';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicamentId': medicamentId,
    'profilId': profilId,
    'periodeDebut': periodeDebut.toIso8601String(),
    'periodeFin': periodeFin.toIso8601String(),
    'prisesPrevues': prisesPrevues,
    'prisesRealisees': prisesRealisees,
    'prisesManquees': prisesManquees,
    'tauxObservance': tauxObservance,
    'detailsPrises': detailsPrises.map((p) => p.toJson()).toList(),
  };

  factory RapportObservance.fromJson(Map<String, dynamic> json) => RapportObservance(
    id: json['id'],
    medicamentId: json['medicamentId'],
    profilId: json['profilId'],
    periodeDebut: DateTime.parse(json['periodeDebut']),
    periodeFin: DateTime.parse(json['periodeFin']),
    prisesPrevues: json['prisesPrevues'],
    prisesRealisees: json['prisesRealisees'],
    prisesManquees: json['prisesManquees'],
    tauxObservance: json['tauxObservance'],
    detailsPrises: (json['detailsPrises'] as List).map((p) => PriseStatut.fromJson(p)).toList(),
  );
}

class MedicamentModule {
  final String id;
  final String nom;
  final String? photoBoite; // Photo de la boîte (obligatoire pour accessibilité)
  final String forme; // 'comprimé', 'sirop', 'injection'
  final String dosage; // '500mg', '250mg/5ml'
  final int frequenceParJour; // 1, 2, 3, 4
  final List<HorairePrise> horairesPrise;
  final int dureeJours;
  final String profilBeneficiaireId; // ID du ProfilFamille
  final String notesMedecin;
  final String? prescritPar;
  final DateTime dateDebut;
  final DateTime dateFin;
  final StockTracker stock;
  final List<PriseStatut> historiquePrises;
  final DateTime dateCreation;

  MedicamentModule({
    required this.id,
    required this.nom,
    this.photoBoite,
    required this.forme,
    required this.dosage,
    required this.frequenceParJour,
    required this.horairesPrise,
    required this.dureeJours,
    required this.profilBeneficiaireId,
    this.notesMedecin = '',
    this.prescritPar,
    required this.dateDebut,
    required this.dateFin,
    required this.stock,
    this.historiquePrises = const [],
    DateTime? dateCreation,
  }) : dateCreation = dateCreation ?? DateTime.now();

  /// Calculer le nombre total de prises prévues
  int get totalPrisesPrevues => frequenceParJour * dureeJours;

  /// Calculer le nombre de prises réalisées
  int get prisesRealisees => historiquePrises.where((p) => p.statut == 'pris').length;

  /// Calculer le taux d'observance
  double get tauxObservance => totalPrisesPrevues > 0 
      ? (prisesRealisees / totalPrisesPrevues) * 100 
      : 0;

  /// Vérifier si le stock est bas
  bool get estStockBas => stock.estStockBas;

  /// Générer un rapport d'observance
  RapportObservance genererRapportObservance(String profilId) {
    return RapportObservance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicamentId: id,
      profilId: profilId,
      periodeDebut: dateDebut,
      periodeFin: dateFin,
      prisesPrevues: totalPrisesPrevues,
      prisesRealisees: prisesRealisees,
      prisesManquees: totalPrisesPrevues - prisesRealisees,
      tauxObservance: tauxObservance,
      detailsPrises: historiquePrises,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'photoBoite': photoBoite,
    'forme': forme,
    'dosage': dosage,
    'frequenceParJour': frequenceParJour,
    'horairesPrise': horairesPrise.map((h) => h.toJson()).toList(),
    'dureeJours': dureeJours,
    'profilBeneficiaireId': profilBeneficiaireId,
    'notesMedecin': notesMedecin,
    'prescritPar': prescritPar,
    'dateDebut': dateDebut.toIso8601String(),
    'dateFin': dateFin.toIso8601String(),
    'stock': stock.toJson(),
    'historiquePrises': historiquePrises.map((p) => p.toJson()).toList(),
    'dateCreation': dateCreation.toIso8601String(),
  };

  factory MedicamentModule.fromJson(Map<String, dynamic> json) => MedicamentModule(
    id: json['id'],
    nom: json['nom'],
    photoBoite: json['photoBoite'],
    forme: json['forme'],
    dosage: json['dosage'],
    frequenceParJour: json['frequenceParJour'],
    horairesPrise: (json['horairesPrise'] as List).map((h) => HorairePrise.fromJson(h)).toList(),
    dureeJours: json['dureeJours'],
    profilBeneficiaireId: json['profilBeneficiaireId'],
    notesMedecin: json['notesMedecin'] ?? '',
    prescritPar: json['prescritPar'],
    dateDebut: DateTime.parse(json['dateDebut']),
    dateFin: DateTime.parse(json['dateFin']),
    stock: StockTracker.fromJson(json['stock']),
    historiquePrises: (json['historiquePrises'] as List).map((p) => PriseStatut.fromJson(p)).toList(),
    dateCreation: DateTime.parse(json['dateCreation']),
  );
}
