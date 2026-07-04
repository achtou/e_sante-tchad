// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicament_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicamentAdapter extends TypeAdapter<Medicament> {
  @override
  final int typeId = 5;

  @override
  Medicament read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medicament(
      id: fields[0] as String,
      nom: fields[1] as String,
      forme: fields[2] as String,
      dosage: fields[3] as String,
      couleur: fields[4] as String,
      stockActuel: fields[5] as int,
      stockInitial: fields[6] as int,
      stockAlerte: fields[7] as int,
      heuresPrise: (fields[8] as List).cast<String>(),
      joursActifs: (fields[9] as List).cast<bool>(),
      dureeTreatement: fields[10] as int,
      dateDebut: fields[11] as DateTime,
      dateFin: fields[12] as DateTime,
      rappelActif: fields[13] as bool,
      notesPharmacien: fields[14] as String,
      prescritPar: fields[15] as String,
      hopital: fields[16] as String,
      prisesJson: (fields[17] as List).cast<String>(),
      dateCreation: fields[18] as DateTime,
      photoOrdonnance: fields[19] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Medicament obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.forme)
      ..writeByte(3)
      ..write(obj.dosage)
      ..writeByte(4)
      ..write(obj.couleur)
      ..writeByte(5)
      ..write(obj.stockActuel)
      ..writeByte(6)
      ..write(obj.stockInitial)
      ..writeByte(7)
      ..write(obj.stockAlerte)
      ..writeByte(8)
      ..write(obj.heuresPrise)
      ..writeByte(9)
      ..write(obj.joursActifs)
      ..writeByte(10)
      ..write(obj.dureeTreatement)
      ..writeByte(11)
      ..write(obj.dateDebut)
      ..writeByte(12)
      ..write(obj.dateFin)
      ..writeByte(13)
      ..write(obj.rappelActif)
      ..writeByte(14)
      ..write(obj.notesPharmacien)
      ..writeByte(15)
      ..write(obj.prescritPar)
      ..writeByte(16)
      ..write(obj.hopital)
      ..writeByte(17)
      ..write(obj.prisesJson)
      ..writeByte(18)
      ..write(obj.dateCreation)
      ..writeByte(19)
      ..write(obj.photoOrdonnance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicamentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PriseMedicamentAdapter extends TypeAdapter<PriseMedicament> {
  @override
  final int typeId = 6;

  @override
  PriseMedicament read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriseMedicament(
      medicamentId: fields[0] as String,
      dateHeure: fields[1] as DateTime,
      statut: fields[2] as String,
      notes: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PriseMedicament obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.medicamentId)
      ..writeByte(1)
      ..write(obj.dateHeure)
      ..writeByte(2)
      ..write(obj.statut)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriseMedicamentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
