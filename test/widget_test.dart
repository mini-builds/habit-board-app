// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:habit_board/model.dart';
import 'package:habit_board/state.dart';

void main() {
  test('JSON encode and decode performance', () {
    var iterations = 100;

    var boards = <Board>[];
    for (var bi = 0; bi < 10; bi++) {
      var entries = <Entry>[];
      for (var ei = 0; ei < 1000; ei++) {
        entries.add(Entry(DateTime.now().subtract(Duration(days: ei))));
      }
      boards.add(Board('id', 'Habit #$bi', entries, TimePeriod.month, 4, false, '09:00', []));
    }

    var state = HabitBoardState(boards, null);
    var dt = DateTime.now();

    for (var i = 0; i < iterations; i++) {
      var s = jsonEncode(state.toJson());
    }

    var timeTakenMs = DateTime.now().millisecondsSinceEpoch - dt.millisecondsSinceEpoch;
    print('Render:');
    print('  1000: ${timeTakenMs}ms');
    print('  1 avg: ${timeTakenMs / iterations}ms');

    var stateString = jsonEncode(state.toJson());

    dt = DateTime.now();

    for (var i = 0; i < iterations; i++) {
      var s = HabitBoardState.fromJson(jsonDecode(stateString));
    }

    timeTakenMs = DateTime.now().millisecondsSinceEpoch - dt.millisecondsSinceEpoch;
    print('Parse:');
    print('  1000: ${timeTakenMs}ms');
    print('  1 avg: ${timeTakenMs / iterations}ms');
  });


}
