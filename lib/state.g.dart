// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitBoardState _$HabitBoardStateFromJson(Map<String, dynamic> json) {
  return HabitBoardState(
    (json['boards'] as List)
        ?.map(
            (e) => e == null ? null : Board.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['selectedBoard'] == null
        ? null
        : Board.fromJson(json['selectedBoard'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$HabitBoardStateToJson(HabitBoardState instance) =>
    <String, dynamic>{
      'boards': instance.boards,
      'selectedBoard': instance.selectedBoard,
    };
