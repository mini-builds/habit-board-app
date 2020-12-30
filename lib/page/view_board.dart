import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_board/date_utils.dart';
import 'package:habit_board/page/board.dart';
import 'package:habit_board/state.dart';
import 'package:table_calendar/table_calendar.dart';

class ViewBoardPage extends StatefulWidget {
  ViewBoardPage();

  @override
  _ViewBoardPageState createState() => _ViewBoardPageState();
}

class _ViewBoardPageState extends State<ViewBoardPage> {
  var calendarController = CalendarController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBoardCubit, HabitBoardState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: Text(state.selectedBoard.name),
          actions: [
            IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BoardPage(state.selectedBoard))),
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ))
          ],
        ),
        body: BlocBuilder<HabitBoardCubit, HabitBoardState>(builder: (context, state) {
          var dateTimes = state.selectedBoard.entries.map((e) => e.date).toList();
          var currentStreak = calculateStreak(state.selectedBoard.timePeriod,
              state.selectedBoard.frequency, DateTime.now(), dateTimes);

          return SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                  title: Text('Current streak: $currentStreak'),
                ),
                TableCalendar(
                  calendarController: calendarController,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  availableCalendarFormats: {CalendarFormat.month: 'Month'},
                  daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.white),
                      weekendStyle: TextStyle(color: Colors.white)),
                  onDaySelected: (day, events, holidays) {
                    context.read<HabitBoardCubit>().toggleDate(state.selectedBoard, day);
                  },
                  headerStyle: HeaderStyle(
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  builders: CalendarBuilders(dayBuilder: (context, date, events) {
                    var currentMonth = calendarController.visibleDays
                        .firstWhere((element) => element.day == 1)
                        .month;
                    var dateChecked = state.selectedBoard.isDateChecked(date);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dateChecked
                                ? date.month == currentMonth
                                    ? Color(0xffFCEE6D)
                                    : Color(0xffECE7B5)
                                : Colors.transparent),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                                color: date.month == currentMonth
                                    ? dateChecked
                                        ? Colors.black
                                        : Colors.white
                                    : dateChecked
                                        ? Colors.black87
                                        : Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        }),
      );
    });
  }
}
