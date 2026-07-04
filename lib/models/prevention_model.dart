import 'package:hive/hive.dart';

part 'prevention_model.g.dart';

@HiveType(typeId: 15)
class ConseilSante extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String titre;

  @HiveField(2)
  String categorie;

  @HiveField(3)
  String description;

  @HiveField(4)
  List<String> pointsCles;

  @HiveField(5)
  String? imageIcon;

  @HiveField(6)
  bool estFavori;

  @HiveField(7)
  DateTime dateCreation;

  @HiveField(8)
  int ordreAffichage;

  ConseilSante({
    required this.id,
    required this.titre,
    required this.categorie,
    required this.description,
    required this.pointsCles,
    this.imageIcon,
    this.estFavori = false,
    required this.dateCreation,
    this.ordreAffichage = 0,
  });
}

@HiveType(typeId: 16)
class CategoriePrevention {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nom;

  @HiveField(2)
  String description;

  @HiveField(3)
  String icon;

  @HiveField(4)
  String color;

  CategoriePrevention({
    required this.id,
    required this.nom,
    required this.description,
    required this.icon,
    required this.color,
  });
}
