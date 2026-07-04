// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prevention_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConseilSanteAdapter extends TypeAdapter<ConseilSante> {
  @override
  final int typeId = 15;

  @override
  ConseilSante read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConseilSante(
      id: fields[0] as String,
      titre: fields[1] as String,
      categorie: fields[2] as String,
      description: fields[3] as String,
      pointsCles: (fields[4] as List).cast<String>(),
      imageIcon: fields[5] as String?,
      estFavori: fields[6] as bool,
      dateCreation: fields[7] as DateTime,
      ordreAffichage: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ConseilSante obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titre)
      ..writeByte(2)
      ..write(obj.categorie)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.pointsCles)
      ..writeByte(5)
      ..write(obj.imageIcon)
      ..writeByte(6)
      ..write(obj.estFavori)
      ..writeByte(7)
      ..write(obj.dateCreation)
      ..writeByte(8)
      ..write(obj.ordreAffichage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConseilSanteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoriePreventionAdapter extends TypeAdapter<CategoriePrevention> {
  @override
  final int typeId = 16;

  @override
  CategoriePrevention read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoriePrevention(
      id: fields[0] as String,
      nom: fields[1] as String,
      description: fields[2] as String,
      icon: fields[3] as String,
      color: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CategoriePrevention obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoriePreventionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
