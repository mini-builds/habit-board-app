import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habit_board/model.dart';
import 'package:habit_board/state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

final daysNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

Future<void> printHello(id) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
        'ic_launcher_foreground');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'habit-board', 'Habit Board Reminders', 'Habit Board Reminders',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics);

    Directory appDocDir = await getApplicationDocumentsDirectory();

    String appDocPath = appDocDir.path;
    print(appDocDir.path);
    var stateFile = File('$appDocPath/habitboardstate.json');
    var exists = await stateFile.exists();

    if (exists) {
      var stateString = await stateFile.readAsString();
      var state = HabitBoardState.fromJson(jsonDecode(stateString));
      var board =  state.boards.firstWhere((element) => element.id.hashCode == id, orElse: () => null);
      print('Id board null: ${board == null}');
      if (board != null && !board.isDateChecked(DateTime.now())) {
        if (board.timePeriod == TimePeriod.day || board.reminderDays.contains(DateTime.now().weekday)) {
          flutterLocalNotificationsPlugin.show(
              id, ' \'${board.name}\'', 'Id: $id ${board.name}', platformChannelSpecifics, payload: board.id);
        }
      }
    }
}

class BoardPage extends StatefulWidget {
  final Board board;

  BoardPage(this.board);

  @override
  _BoardPageState createState() => _BoardPageState(this.board);
}

class _BoardPageState extends State<BoardPage> {
  TextEditingController _controller;
  TimePeriod _timePeriod;
  TextEditingController _frequencyController;
  String _error;
  String _frequencyError;

  bool _reminderEnabled;
  TextEditingController _reminderTimeController;
  // TimeOfDay _timeOfDay;
  List<int> _reminderDays;

  _BoardPageState(Board board) {
    _controller = TextEditingController(text: board == null ? '' : board.name);
    _frequencyController =
        TextEditingController(text: board == null ? '1' : board.frequency.toString());
    _timePeriod = board == null ? TimePeriod.day : board.timePeriod;

    _reminderTimeController = TextEditingController(text: board == null ? '09:00' : board.reminderTime);
    _reminderEnabled = board == null ? true : board.reminderEnabled;
    _reminderDays = board == null ? [] : board.reminderDays;
  }

  void checkFrequency(String v) {
    var freq = int.parse(v);
    if ((_timePeriod == TimePeriod.week || _timePeriod == TimePeriod.month) && freq < 1) {
      _frequencyError = 'Frequency must be >= 1';
    } else if (_timePeriod == TimePeriod.week && freq > 7) {
      _frequencyError = 'Frequency must be <= 7';
    } else if (_timePeriod == TimePeriod.month && freq > 31) {
      _frequencyError = 'Frequency must be <= 31';
    } else {
      _frequencyError = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.board == null ? 'Create a Board' : 'Edit ${widget.board.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _error != null || _frequencyError != null
                ? null
                : () {
                    if (_controller.text == '') {
                      setState(() {
                        _error = 'A board name can\'t be blank';
                      });
                    } else {
                      if (widget.board == null) {
                        var id = Uuid().v4().toString();
                        context.read<HabitBoardCubit>().addBoard(Board(
                            id, _controller.text, [], _timePeriod, _timePeriod == TimePeriod.day ? 1 : int.parse(_frequencyController.text), _reminderEnabled, _reminderTimeController.text, _reminderDays));
                        final int helloAlarmID = id.hashCode;
                        AndroidAlarmManager.cancel(helloAlarmID);
                        if (_reminderEnabled) {
                          AndroidAlarmManager.periodic(const Duration(days: 1), helloAlarmID, printHello,
                              startAt: DateTime.now().add(Duration(minutes: 1)))
                              .then((value) => print(value));
                        }
                      } else {
                        context.read<HabitBoardCubit>().editBoard(widget.board, _controller.text,
                            _timePeriod, _timePeriod == TimePeriod.day ? 1 : int.parse(_frequencyController.text), _reminderEnabled, _reminderTimeController.text, _reminderDays);
                        
                        final int helloAlarmID = widget.board.id.hashCode;
                        AndroidAlarmManager.cancel(helloAlarmID);
                        if (_reminderEnabled) {
                          AndroidAlarmManager.periodic(
                              const Duration(minutes: 1), helloAlarmID, printHello,
                              startAt: DateTime.now().add(Duration(minutes: 1)),
                              rescheduleOnReboot: true
                          )
                              .then((value) => print(value));
                        }
                      }
                      Navigator.pop(context);
                    }
                  },
          )
        ],
      ),
      body: BlocBuilder<HabitBoardCubit, HabitBoardState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Board Name'),
                ),
                TextField(
                  decoration: InputDecoration(
                      hintText: 'Name',
                      errorText: _error,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintStyle: TextStyle(color: Colors.white60)),
                  controller: _controller,
                  onChanged: (v) {
                    setState(() {
                      if (state.boards.any((element) =>
                          element.name.toLowerCase() == v.toLowerCase() &&
                          element != widget.board)) {
                        _error = 'A board with name $v already exists';
                      } else if (v == '') {
                        _error = 'A board name can\'t be blank';
                      } else {
                        _error = null;
                      }
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Streak Type'),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Color(0xff25282F),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: DropdownButton<TimePeriod>(
                      value: _timePeriod,
                      underline: Container(),
                      dropdownColor: Color(0xff25282F),
                      items: TimePeriod.values
                          .map((tp) => DropdownMenuItem<TimePeriod>(
                                value: tp,
                                child: Text(
                                  tp.toString().replaceAll('TimePeriod.', ''),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _timePeriod = v;
                          checkFrequency(_frequencyController.text);
                        });
                      }),
                ),
                _timePeriod != TimePeriod.day
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Frequency'),
                      )
                    : Container(),
                _timePeriod != TimePeriod.day
                    ? TextField(
                        decoration: InputDecoration(
                            hintText: 'Frequency',
                            errorText: _frequencyError,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintStyle: TextStyle(color: Colors.white60)),
                        controller: _frequencyController,
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          setState(() {
                            checkFrequency(v);
                          });
                        },
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Reminder'),
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 5,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,

                        child: IgnorePointer(
                          child: TextField(
                            decoration: InputDecoration(
                                hintText: 'Reminder Time',
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                hintStyle: TextStyle(color: Colors.white60)),
                            controller: _reminderTimeController,

                          ),
                        ),
                        onTap: () async {
                          var parts = _reminderTimeController.text.split(':');

                          TimeOfDay selectedTime = await showTimePicker(
                            initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
                            context: context
                          );

                          if (selectedTime != null) {
                            setState(() {
                              _reminderTimeController.text = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                              _reminderEnabled = true;
                            });
                          }
                        },
                      ),
                    ),
                    Spacer(),
                    Switch(
                        value: _reminderEnabled,
                        onChanged: (v) async {
                          setState(()  {
                            _reminderEnabled = !_reminderEnabled;
                          });
                        })
                  ],
                ),
                _timePeriod != TimePeriod.day
                    ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    color: Color(0x11FCEE6D),
                    child: ToggleButtons(
                      children: [1, 2, 3, 4, 5, 6, 7].map((e) => Text(daysNames[e-1], style: TextStyle(fontWeight: FontWeight.bold, color: _reminderDays.contains(e) ? Colors.black : Colors.white),)).toList(),
                      fillColor: Color(0xffFCEE6D),
                      onPressed: (index) {
                        setState(() {
                          if (!_reminderDays.contains(index + 1)) {
                            _reminderDays.add(index + 1);
                          } else {
                            _reminderDays.remove(index + 1);
                          }
                        });
                      },
                      isSelected: [1, 2, 3, 4, 5, 6, 7].map((e) => _reminderDays.contains(e)).toList()
                    ),
                  ),
                ) : Container()
              ],
            ),
          );
        },
      ),
    );
  }



}
