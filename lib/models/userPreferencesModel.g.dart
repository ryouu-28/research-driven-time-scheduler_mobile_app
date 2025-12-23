// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userPreferencesModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesModelAdapter extends TypeAdapter<UserPreferencesModel> {
  @override
  final int typeId = 5;

  @override
  UserPreferencesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferencesModel(
      maxDailyTasks: fields[0] as int,
      preferredTimeSlot: fields[1] as String,
      scheduleStyle: fields[2] as String,
      needsReminders: fields[3] as bool,
      personalityType: fields[4] as String,
      getOverwhelmed: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferencesModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.maxDailyTasks)
      ..writeByte(1)
      ..write(obj.preferredTimeSlot)
      ..writeByte(2)
      ..write(obj.scheduleStyle)
      ..writeByte(3)
      ..write(obj.needsReminders)
      ..writeByte(4)
      ..write(obj.personalityType)
      ..writeByte(5)
      ..write(obj.getOverwhelmed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
