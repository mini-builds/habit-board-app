// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_board/date_utils.dart';

import 'package:habit_board/model.dart';
import 'package:habit_board/state.dart';

void main() {
  test('truncateDate timePeriod == day', () {
    var d = DateTime(2020, 12, 28, 12, 35, 1, 1);
    var result = truncateDate(TimePeriod.day, d);

    expect(result, DateTime(2020, 12, 28));
  });

  test('truncateDate timePeriod == week', () {
    var d = DateTime(2020, 12, 29, 12, 35, 1, 1);
    var result = truncateDate(TimePeriod.week, d);

    expect(result, DateTime(2020, 12, 28));

    var d2 = DateTime(2020, 12, 28, 0, 0, 0, 0);
    var result2 = truncateDate(TimePeriod.week, d2);

    expect(result2, DateTime(2020, 12, 28));
  });

  test('truncateDate timePeriod == month', () {
    var d = DateTime(2020, 12, 29, 12, 35, 1, 1);
    var result = truncateDate(TimePeriod.month, d);

    expect(result, DateTime(2020, 12, 1));

    var d2 = DateTime(2020, 12, 1, 0, 0, 0, 0);
    var result2 = truncateDate(TimePeriod.month, d2);

    expect(result2, DateTime(2020, 12, 1));
  });

  test('createDateRange timePeriod == day', () {
    var start = DateTime(2020, 12, 25, 12, 35, 1, 1);
    var end = DateTime(2020, 12, 28, 12, 35, 1, 1);
    var result = createDateRange(TimePeriod.day, start, end);

    expect(result, [
      DateTime(2020, 12, 25),
      DateTime(2020, 12, 26),
      DateTime(2020, 12, 27),
      DateTime(2020, 12, 28)
    ]);
  });

  test('createDateRange timePeriod == week', () {
    var start = DateTime(2020, 12, 1, 12, 35, 1, 1);
    var end = DateTime(2020, 12, 28, 12, 35, 1, 1);
    var result = createDateRange(TimePeriod.week, start, end);

    expect(result, [
      DateTime(2020, 11, 30),
      DateTime(2020, 12, 7),
      DateTime(2020, 12, 14),
      DateTime(2020, 12, 21),
      DateTime(2020, 12, 28)
    ]);
  });

  test('createDateRange timePeriod == month', () {
    var start = DateTime(2020, 6, 10, 12, 35, 1, 1);
    var end = DateTime(2020, 12, 28, 12, 35, 1, 1);
    var result = createDateRange(TimePeriod.month, start, end);

    expect(result, [
      DateTime(2020, 6, 1),
      DateTime(2020, 7, 1),
      DateTime(2020, 8, 1),
      DateTime(2020, 9, 1),
      DateTime(2020, 10, 1),
      DateTime(2020, 11, 1),
      DateTime(2020, 12, 1),
    ]);
  });
}
