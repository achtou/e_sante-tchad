// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sante_maternelle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GrossesseAdapter extends TypeAdapter<Grossesse> {
  @override
  final int typeId = 10;

  @override
  Grossesse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Grossesse(
      id: fields[0] as String,
      dateDebut: fields[1] as DateTime,
      dateAccouchementPrevue: fields[2] as DateTime,
      dateAccouchementReelle: fields[3] as DateTime?,
      nombreEnfantsPrecedents: fields[4] as int,
      groupeSanguin: fields[5] as String,
      facteursRisques: fields[6] as String?,
      estTerminee: fields[7] as bool,
      dateCreation: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Grossesse obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dateDebut)
      ..writeByte(2)
      ..write(obj.dateAccouchementPrevue)
      ..writeByte(3)
      ..write(obj.dateAccouchementReelle)
      ..writeByte(4)
      ..write(obj.nombreEnfantsPrecedents)
      ..writeByte(5)
      ..write(obj.groupeSanguin)
      ..writeByte(6)
      ..write(obj.facteursRisques)
      ..writeByte(7)
      ..write(obj.estTerminee)
      ..writeByte(8)
      ..write(obj.dateCreation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrossesseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VisitePrenataleAdapter extends TypeAdapter<VisitePrenatale> {
  @override
  final int typeId = 11;

  @override
  VisitePrenatale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VisitePrenatale(
      id: fields[0] as String,
      grossesseId: fields[1] as String,
      dateVisite: fields[2] as DateTime,
      poids: fields[3] as double,
      tensionArterielle: fields[4] as double,
      notes: fields[5] as String?,
      examensEffectues: fields[6] as bool,
      examensDetails: fields[7] as String?,
      dateCreation: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, VisitePrenatale obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.grossesseId)
      ..writeByte(2)
      ..write(obj.dateVisite)
      ..writeByte(3)
      ..write(obj.poids)
      ..writeByte(4)
      ..write(obj.tensionArterielle)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.examensEffectues)
      ..writeByte(7)
      ..write(obj.examensDetails)
      ..writeByte(8)
      ..write(obj.dateCreation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitePrenataleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnfantAdapter extends TypeAdapter<Enfant> {
  @override
  final int typeId = 12;

  @override
  Enfant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Enfant(
      id: fields[0] as String,
      grossesseId: fields[1] as String?,
      nom: fields[2] as String,
      dateNaissance: fields[3] as DateTime,
      poidsNaissance: fields[4] as double,
      tailleNaissance: fields[5] as double,
      sexe: fields[6] as String,
      groupeSanguin: fields[7] as String,
      dateCreation: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Enfant obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.grossesseId)
      ..writeByte(2)
      ..write(obj.nom)
      ..writeByte(3)
      ..write(obj.dateNaissance)
      ..writeByte(4)
      ..write(obj.poidsNaissance)
      ..writeByte(5)
      ..write(obj.tailleNaissance)
      ..writeByte(6)
      ..write(obj.sexe)
      ..writeByte(7)
      ..write(obj.groupeSanguin)
      ..writeByte(8)
      ..write(obj.dateCreation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnfantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VaccinationAdapter extends TypeAdapter<Vaccination> {
  @override
  final int typeId = 13;

  @override
  Vaccination read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vaccination(
      id: fields[0] as String,
      enfantId: fields[1] as String,
      nomVaccin: fields[2] as String,
      datePrevue: fields[3] as DateTime,
      dateAdministree: fields[4] as DateTime?,
      estAdministre: fields[5] as bool,
      notes: fields[6] as String?,
      dateCreation: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Vaccination obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.enfantId)
      ..writeByte(2)
      ..write(obj.nomVaccin)
      ..writeByte(3)
      ..write(obj.datePrevue)
      ..writeByte(4)
      ..write(obj.dateAdministree)
      ..writeByte(5)
      ..write(obj.estAdministre)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.dateCreation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccinationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SuiviCroissanceAdapter extends TypeAdapter<SuiviCroissance> {
  @override
  final int typeId = 14;

  @override
  SuiviCroissance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SuiviCroissance(
      id: fields[0] as String,
      enfantId: fields[1] as String,
      dateMesure: fields[2] as DateTime,
      poids: fields[3] as double,
      taille: fields[4] as double,
      perimetreCranien: fields[5] as double?,
      notes: fields[6] as String?,
      dateCreation: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SuiviCroissance obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.enfantId)
      ..writeByte(2)
      ..write(obj.dateMesure)
      ..writeByte(3)
      ..write(obj.poids)
      ..writeByte(4)
      ..write(obj.taille)
      ..writeByte(5)
      ..write(obj.perimetreCranien)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.dateCreation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuiviCroissanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
