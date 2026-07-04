// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dossier_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DossierMedicalAdapter extends TypeAdapter<DossierMedical> {
  @override
  final int typeId = 2;

  @override
  DossierMedical read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DossierMedical(
      id: fields[0] as String,
      nom: fields[1] as String,
      prenom: fields[2] as String,
      dateNaissance: fields[3] as DateTime,
      sexe: fields[4] as String,
      telephone: fields[5] as String,
      ville: fields[6] as String,
      photoPath: fields[7] as String?,
      groupeSanguin: fields[8] as String,
      poids: fields[9] as double,
      taille: fields[10] as double,
      allergies: (fields[11] as List).cast<String>(),
      maladiesChroniques: (fields[12] as List).cast<String>(),
      traitementsEnCours: fields[13] as String,
      nomContactUrgence: fields[14] as String,
      telContactUrgence: fields[15] as String,
      vaccinsEffectues: (fields[16] as List).cast<String>(),
      consultationsJson: (fields[17] as List).cast<String>(),
      dateCreation: fields[18] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DossierMedical obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.prenom)
      ..writeByte(3)
      ..write(obj.dateNaissance)
      ..writeByte(4)
      ..write(obj.sexe)
      ..writeByte(5)
      ..write(obj.telephone)
      ..writeByte(6)
      ..write(obj.ville)
      ..writeByte(7)
      ..write(obj.photoPath)
      ..writeByte(8)
      ..write(obj.groupeSanguin)
      ..writeByte(9)
      ..write(obj.poids)
      ..writeByte(10)
      ..write(obj.taille)
      ..writeByte(11)
      ..write(obj.allergies)
      ..writeByte(12)
      ..write(obj.maladiesChroniques)
      ..writeByte(13)
      ..write(obj.traitementsEnCours)
      ..writeByte(14)
      ..write(obj.nomContactUrgence)
      ..writeByte(15)
      ..write(obj.telContactUrgence)
      ..writeByte(16)
      ..write(obj.vaccinsEffectues)
      ..writeByte(17)
      ..write(obj.consultationsJson)
      ..writeByte(18)
      ..write(obj.dateCreation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DossierMedicalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
