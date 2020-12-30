// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Board _$BoardFromJson(Map<String, dynamic> json) {
  return Board(
    json['name'] as String,
    (json['entries'] as List)
        .map((e) => Entry.fromJson(e as Map<String, dynamic>))
        .toList(),
    _$enumDecode(_$TimePeriodEnumMap, json['timePeriod']),
    json['frequency'] as int,
  );
}

Map<String, dynamic> _$BoardToJson(Board instance) => <String, dynamic>{
      'name': instance.name,
      'entries': instance.entries,
      'timePeriod': _$TimePeriodEnumMap[instance.timePeriod],
      'frequency': instance.frequency,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

const _$TimePeriodEnumMap = {
  TimePeriod.day: 'day',
  TimePeriod.week: 'week',
  TimePeriod.month: 'month',
};

Entry _$EntryFromJson(Map<String, dynamic> json) {
  return Entry(
    DateTime.parse(json['date'] as String),
  );
}

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
      'date': instance.date.toIso8601String(),
    };
