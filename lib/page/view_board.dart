import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_board/date_utils.dart';
import 'package:habit_board/page/board.dart';
import 'package:habit_board/page/year_view.dart';
import 'package:habit_board/state.dart';
import 'package:table_calendar/table_calendar.dart';

class ViewBoardPage extends StatefulWidget {
  ViewBoardPage();

  @override
  _ViewBoardPageState createState() => _ViewBoardPageState();
}

class _ViewBoardPageState extends State<ViewBoardPage> {
  var calendarController = CalendarController();
  var year = DateTime.now().year;
  var pageIndex = 0;
  var dragDeltaX = 0.0;
  var panning = true;

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
          var width = MediaQuery.of(context).size.width;

          return SingleChildScrollView(
            child: Column(
              children: [
                pageIndex == 0
                    ? ListTile(
                        leading: Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                        ),
                        title: Text('Current streak: $currentStreak'),
                      )
                    : Container(),
                pageIndex == 0
                    ? TableCalendar(
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
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                  icon: Icon(Icons.chevron_left, color: Colors.white),
                                  onPressed: () async {
                                    setState(() {
                                      panning = false;
                                      dragDeltaX = width;
                                    });

                                    await Future.delayed(Duration(milliseconds: 200));
                                    setState(() {
                                      year--;
                                      panning = true;
                                      dragDeltaX = -width;
                                    });

                                    await Future.delayed(Duration(milliseconds: 20));
                                    setState(() {
                                      panning = false;
                                      dragDeltaX = 0;
                                    });
                                  }),
                              Expanded(
                                  child: Text(
                                '$year',
                                textScaleFactor: 1.2,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              )),
                              IconButton(
                                  icon: Icon(Icons.chevron_right, color: Colors.white),
                                  onPressed: () async {
                                    setState(() {
                                      panning = false;
                                      dragDeltaX = -width;
                                    });

                                    await Future.delayed(Duration(milliseconds: 200));
                                    setState(() {
                                      panning = true;
                                      year++;
                                      dragDeltaX = width;
                                    });

                                    await Future.delayed(Duration(milliseconds: 20));
                                    setState(() {
                                      panning = false;
                                      dragDeltaX = 0;
                                    });
                                  }),
                            ],
                          ),
                          GestureDetector(
                            child: AnimatedContainer(
                              transform: Matrix4.translationValues(dragDeltaX, 0, 0),
                              duration: Duration(milliseconds: panning ? 0 : 200),
                              curve: Curves.easeInOut,
                              child: CustomPaint(
                                size: Size(width, width * 1.55),
                                painter: YearViewPainter(year, state.selectedBoard),
                              ),
                            ),
                            onPanUpdate: (details) {
                              setState(() {
                                panning = true;
                                dragDeltaX += details.delta.dx;
                              });
                            },
                            onPanEnd: (details) async {
                              if (-50 < dragDeltaX && dragDeltaX < 50) {
                                setState(() {
                                  panning = false;
                                  dragDeltaX = 0;
                                });
                                return;
                              }

                              var movingLeft = dragDeltaX < 0;

                              setState(() {
                                panning = false;
                                if (movingLeft) {
                                  dragDeltaX = -width;
                                } else {
                                  dragDeltaX = width;
                                }
                              });

                              await Future.delayed(Duration(milliseconds: 200));
                              setState(() {
                                panning = true;
                                if (movingLeft) {
                                  dragDeltaX = width;
                                } else {
                                  dragDeltaX = -width;
                                }
                              });

                              await Future.delayed(Duration(milliseconds: 10));
                              setState(() {
                                panning = false;
                                if (movingLeft) {
                                  year++;
                                } else {
                                  year--;
                                }
                                dragDeltaX = 0;
                              });
                            },
                          )
                        ],
                      ),
              ],
            ),
          );
        }),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 96.0),
          child: BottomNavigationBar(
            currentIndex: pageIndex,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Month'),
              BottomNavigationBarItem(icon: Icon(Icons.view_comfortable), label: 'Year')
            ],
            onTap: (p) {
              setState(() {
                pageIndex = p;
              });
            },
          ),
        ),
      );
    });
  }
}
