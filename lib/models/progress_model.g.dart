// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressAdapter extends TypeAdapter<Progress> {
  @override
  final int typeId = 4;

  @override
  Progress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Progress(
      userId: fields[0] as String,
      category: fields[1] as String,
      completedLessons: fields[2] as int,
      totalLessons: fields[3] as int,
      totalQuizzes: fields[4] as int,
      averageScore: fields[5] as int,
      currentDifficulty: fields[6] as String,
      lastUpdated: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Progress obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.completedLessons)
      ..writeByte(3)
      ..write(obj.totalLessons)
      ..writeByte(4)
      ..write(obj.totalQuizzes)
      ..writeByte(5)
      ..write(obj.averageScore)
      ..writeByte(6)
      ..write(obj.currentDifficulty)
      ..writeByte(7)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
