import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

enum TimePeriod {
  day, week, month
}

@JsonSerializable(nullable: false)
class Board {
  final String id;
  final String name;
  final List<Entry> entries;
  final TimePeriod timePeriod;
  final int frequency;

  final bool reminderEnabled;
  final String reminderTime;
  final List<int> reminderDays;

  Board(this.id, this.name, this.entries, this.timePeriod, this.frequency, this.reminderEnabled, this.reminderTime, this.reminderDays);

  bool isDateChecked(DateTime d) {
    return this.entries.firstWhere((e) => e.date.year == d.year && e.date.month == d.month && e.date.day == d.day, orElse: () => null) != null;
  }

  void toggle(DateTime d) {
    var existingEntry = this.entries.firstWhere((e) => e.date.year == d.year && e.date.month == d.month && e.date.day == d.day, orElse: () => null);

    if (existingEntry == null) {
      this.entries.add(Entry(d));
    } else {
      this.entries.remove(existingEntry);
    }
  }

  factory Board.fromJson(Map<String, dynamic> json) => _$BoardFromJson(json);
  Map<String, dynamic> toJson() => _$BoardToJson(this);
}

@JsonSerializable(nullable: false)
class Entry {
  final DateTime date;

  Entry(this.date);

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
  Map<String, dynamic> toJson() => _$EntryToJson(this);
}