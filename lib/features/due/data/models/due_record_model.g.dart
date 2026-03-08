// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'due_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DueRecordModelAdapter extends TypeAdapter<DueRecordModel> {
  @override
  final int typeId = 4;

  @override
  DueRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DueRecordModel(
      id: fields[0] as String,
      customerName: fields[1] as String,
      phoneNumber: fields[2] as String,
      amount: fields[3] as double,
      date: fields[4] as DateTime,
      note: fields[5] as String?,
      isPaid: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DueRecordModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerName)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.isPaid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DueRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
