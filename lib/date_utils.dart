import 'package:habit_board/model.dart';

DateTime truncateDate(TimePeriod timePeriod, DateTime dt) {
  if (timePeriod == TimePeriod.day) {
    return DateTime.utc(dt.year, dt.month, dt.day);
  }

  if (timePeriod == TimePeriod.week) {
    return DateTime.utc(dt.year, dt.month, dt.day).subtract(Duration(days: dt.weekday - 1));
  }

  return DateTime.utc(dt.year, dt.month, dt.day).subtract(Duration(days: dt.day - 1));
}

List<DateTime> createDateRange(TimePeriod timePeriod, DateTime start, DateTime end) {
  var current = truncateDate(timePeriod, start);

  var result = <DateTime>[];

  while (current.isBefore(end)) {
    result.add(current);
    if (timePeriod == TimePeriod.day) {
      current = current.add(Duration(days: 1));
    }
    if (timePeriod == TimePeriod.week) {
      current = current.add(Duration(days: 7));
    }
    if (timePeriod == TimePeriod.month) {
      current = truncateDate(
          TimePeriod.month, current.add(Duration(days: 31)));
    }
  }

  return result;
}

int calculateStreak(TimePeriod timePeriod, int frequency, DateTime end, List<DateTime> dateTimes) {
  // TODO: fix weird day light saving time issue
  if (dateTimes.isEmpty) {
    return 0;
  }
  var currentStreak = 0;
  var frequencyLookUp = Map<DateTime, int>();

  for (var d in dateTimes) {
    var trunDate = truncateDate(timePeriod, d);
    if (frequencyLookUp.containsKey(trunDate)) {
      frequencyLookUp[trunDate] = frequencyLookUp[trunDate] + 1;
    } else {
      frequencyLookUp[trunDate] = 1;
    }
  }

  var start = dateTimes.reduce((value, element) => element.isBefore(value) ? element : value);
  var range = createDateRange(timePeriod, start, end);

  for (var i = range.length - 1; i >= 0; i--) {
    if (i == range.length - 1 && (frequencyLookUp[range[i]] ?? 0) < frequency) {
      continue;
    }
    if ((frequencyLookUp[range[i]] ?? 0) >= frequency) {
      currentStreak++;
    } else {
      break;
    }
  }

  return currentStreak;
}
