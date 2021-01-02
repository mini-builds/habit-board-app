import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_board/model.dart';

class YearViewPainter extends CustomPainter {
  final _months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
  final Board board;
  final int boardHash;
  final int year;

  YearViewPainter(this.year, this.board) : this.boardHash = board.hashCode;

  @override
  void paint(Canvas canvas, Size size) {
    var p = Paint();
    p.color = Color(0xffFCEE6D);

    var p2 = Paint();
    p2.color = Colors.white60;

    var boxWidth = ((size.width - 6) / 13.0).floorToDouble();
    var boxHeight = ((size.width - 6) / 13.0).floorToDouble() * 0.65;
    var circleRadius = boxWidth / 2.0 - 10.0;
    var smallCircleRadius = boxWidth / 16.0;

    for (var dayIndex = 0; dayIndex < 31; dayIndex++) {
      final TextPainter textPainter = TextPainter(
          text: TextSpan(text: '${dayIndex + 1}', style: TextStyle(color: Colors.white)),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr)
        ..layout(minWidth: 12, );
      textPainter.paint(canvas, Offset(12.0, (dayIndex + 1) * boxHeight + (boxHeight - textPainter.height) / 2.0));

      for (var monthIndex = 0; monthIndex < _months.length; monthIndex++) {
        var daysInMonth = DateTime(year, monthIndex + 2, 0).day;

        if (dayIndex == 0) {
          final TextPainter textPainter = TextPainter(
              text: TextSpan(text: _months[monthIndex], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr)
            ..layout(minWidth: boxWidth, maxWidth: boxWidth);
          textPainter.paint(canvas, Offset(6 + (monthIndex + 1) * boxWidth, dayIndex * boxHeight));
        }

        var dt = DateTime(year, monthIndex + 1, dayIndex + 1);

        if (board.isDateChecked(dt)) {
          canvas.drawCircle(
              Offset(6 + (monthIndex + 1.5) * boxWidth, (dayIndex + 1.5) * boxHeight), circleRadius,
              p);
        } else if (dayIndex < daysInMonth) {
          canvas.drawCircle(
              Offset(6 + (monthIndex + 1.5) * boxWidth, (dayIndex + 1.5) * boxHeight), smallCircleRadius,
              p2);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is YearViewPainter) {
      if (boardHash == oldDelegate.boardHash && year == oldDelegate.year) {
        return false;
      }
    }

    return true;
  }
}
