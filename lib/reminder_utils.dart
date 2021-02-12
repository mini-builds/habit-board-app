
import 'dart:convert';
import 'dart:io';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habit_board/model.dart';
import 'package:habit_board/state.dart';
import 'package:path_provider/path_provider.dart';

Future<void> createNotification(id) async {
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

void scheduleReminder(Board board) {
  AndroidAlarmManager.cancel(board.id.hashCode);
  if (board.reminderEnabled) {
    AndroidAlarmManager.periodic(const Duration(days: 1), board.id.hashCode, createNotification,
        startAt: DateTime.now().add(Duration(minutes: 1)), rescheduleOnReboot: true)
        .then((value) => print('Reminder success: $value'));
  }
}