// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maladie_chronique_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaladieChroniqueAdapter extends TypeAdapter<MaladieChronique> {
  @override
  final int typeId = 17;

  @override
  MaladieChronique read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaladieChronique(
      id: fields[0] as String,
      nom: fields[1] as String,
      type: fields[2] as String,
      description: fields[3] as String,
      dateDiagnostic: fields[4] as DateTime,
      mesures: (fields[5] as List).cast<MesureVitale>(),
      traitements: (fields[6] as List).cast<String>(),
      medecinTraitant: fields[7] as String,
      telephoneMedecin: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MaladieChronique obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.dateDiagnostic)
      ..writeByte(5)
      ..write(obj.mesures)
      ..writeByte(6)
      ..write(obj.traitements)
      ..writeByte(7)
      ..write(obj.medecinTraitant)
      ..writeByte(8)
      ..write(obj.telephoneMedecin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaladieChroniqueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MesureVitaleAdapter extends TypeAdapter<MesureVitale> {
  @override
  final int typeId = 18;

  @override
  MesureVitale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MesureVitale(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      type: fields[2] as String,
      valeur: fields[3] as double,
      notes: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MesureVitale obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.valeur)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MesureVitaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
