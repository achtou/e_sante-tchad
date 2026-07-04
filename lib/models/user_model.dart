import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nom;

  @HiveField(2)
  String telephone;

  @HiveField(3)
  String motDePasse;

  @HiveField(4)
  String ville;

  @HiveField(5)
  DateTime dateInscription;

  UserModel({
    required this.id,
    required this.nom,
    required this.telephone,
    required this.motDePasse,
    required this.ville,
    required this.dateInscription,
  });
}
