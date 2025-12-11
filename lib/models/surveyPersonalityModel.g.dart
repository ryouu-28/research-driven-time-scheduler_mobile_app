// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surveyPersonalityModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurveyPersonalityAdapter extends TypeAdapter<SurveyPersonality> {
  @override
  final int typeId = 2;

  @override
  SurveyPersonality read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurveyPersonality(
      personality: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SurveyPersonality obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.personality);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyPersonalityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
