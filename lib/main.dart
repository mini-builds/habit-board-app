import 'dart:io';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_board/date_utils.dart';
import 'package:habit_board/model.dart';
import 'package:habit_board/page/board.dart';
import 'package:habit_board/page/view_board.dart';
import 'package:habit_board/state.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

Future<void> main() async {

  runApp(BlocProvider(
    create: (BuildContext context) => HabitBoardCubit()..loadState(),
    child: HabitBoardApp(),
  ));
  await AndroidAlarmManager.initialize();
}

class HabitBoardApp extends StatefulWidget {
  @override
  _HabitBoardAppState createState() => _HabitBoardAppState();
}

class _HabitBoardAppState extends State<HabitBoardApp> with WidgetsBindingObserver {
  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutterio', 'beautiful apps'],
    contentUrl: 'https://flutter.io',
    childDirected: false,
    testDevices: <String>[], // Android emulators are considered test devices
  );

  BannerAd myBanner = BannerAd(
    // Replace the testAdUnitId with an ad unit id from the AdMob dash.
    // https://developers.google.com/admob/android/test-ads
    // https://developers.google.com/admob/ios/test-ads
    adUnitId: BannerAd.testAdUnitId,
    size: AdSize.smartBanner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff29323F),
        appBarTheme: AppBarTheme(color: Color(0xff191E26)),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyText1: Theme.of(context).textTheme.bodyText1.apply(color: Colors.red),
          bodyText2: Theme.of(context).textTheme.bodyText2.apply(color: Colors.white),
          headline1: Theme.of(context).textTheme.headline1.apply(color: Colors.white),
          headline2: Theme.of(context).textTheme.headline2.apply(color: Colors.white),
          headline3: Theme.of(context).textTheme.headline3.apply(color: Colors.white),
          headline4: Theme.of(context).textTheme.headline4.apply(color: Colors.white),
          headline5: Theme.of(context).textTheme.headline5.apply(color: Colors.white),
          headline6: Theme.of(context).textTheme.headline6.apply(color: Colors.white),
          subtitle1: Theme.of(context).textTheme.subtitle1.apply(color: Colors.white),
          subtitle2: Theme.of(context).textTheme.subtitle2.apply(color: Colors.red),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white54),
          border: new OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(4.0),
            ),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          focusColor: Color(0xffffffff),
          filled: true,
          fillColor: Color(0xff25282F),
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        ),
      ),
      home: MainPage('Habit Board'),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    myBanner
      ..load()
      ..show(
        anchorOffset: 0.0,
        horizontalCenterOffset: 0.0,
        anchorType: AnchorType.bottom,
      );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      context.read<HabitBoardCubit>().saveState();
    }
  }
}

class MainPage extends StatelessWidget {
  final String title;

  MainPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => BoardPage(null)));
            },
          ),
          PopupMenuButton<String>(itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: 'export',
                child: Text("Export Boards", style: TextStyle(color: Colors.black)),
              ),
              PopupMenuItem(
                value: 'import',
                child: Text("Import Boards", style: TextStyle(color: Colors.black)),
              )
            ];
          }, onSelected: (v) async {
            if (v == 'export') {
              var tempDir = await getTemporaryDirectory();

              var dateFormat = DateFormat('yyyy-MM-dd');

              var file =
                  File('${tempDir.path}/habitboard-${dateFormat.format(DateTime.now())}.csv');

              var csvData = ['Board,Date,Streak Type,Frequency'];
              var boards = BlocProvider.of<HabitBoardCubit>(context).state.boards;
              boards.forEach((b) => b.entries.forEach((e) => csvData
                  .add('${b.name},${dateFormat.format(e.date)},${b.timePeriod},${b.frequency}')));

              await file.writeAsString(csvData.join('\n'));

              Share.shareFiles([file.path]);
            }

            if (v == 'import') {
              FilePickerResult result = await FilePicker.platform.pickFiles();

              if (result != null) {
                File file = File(result.files.single.path);
                var lines = (await file.readAsString()).split('\n');
                Map<String, Board> boardMap = Map.fromIterable(
                    BlocProvider.of<HabitBoardCubit>(context).state.boards,
                    key: (e) => e.id,
                    value: (e) => e);
                var dateFormat = DateFormat('yyyy-MM-dd');
                for (int i = 1; i < lines.length; i++) {
                  var parts = lines[i].split(',');
                  var id = parts[0];
                  var boardName = parts[1];
                  var date = dateFormat.parse(parts[2]);
                  var timePeriod = TimePeriod.values.singleWhere((t) => parts[3] == t.toString());
                  var frequency = int.parse(parts[4]);

                  boardMap.putIfAbsent(boardName, () {
                    var board = Board(id, boardName, [], timePeriod, frequency, false, '09:00', []);
                    BlocProvider.of<HabitBoardCubit>(context).addBoard(board);
                    return board;
                  });

                  if (!boardMap[boardName].isDateChecked(date)) {
                    boardMap[boardName].toggle(date);
                  }
                }
              }
            }
          })
        ],
      ),
      body: BlocBuilder<HabitBoardCubit, HabitBoardState>(
        builder: (context, state) {
          if (state.boards.isEmpty) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(height: 16.0),
                      Text('No boards found', textAlign: TextAlign.center, textScaleFactor: 1.2),
                      Container(height: 16.0),
                      Text('Click \'+\' to add a board',
                          textAlign: TextAlign.center, textScaleFactor: 1.2),
                    ],
                  ),
                ),
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 92.0),
            child: ListView.builder(
              itemCount: state.boards.length,
              itemBuilder: (context, index) {
                var board = state.boards[index];
                return Dismissible(
                key: Key(board.name),
                background: Container(
                  color: Colors.red,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Icon(Icons.delete, color: Colors.black54),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  child: Row(
                    children: [
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Icon(Icons.delete, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                child: ListTile(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(board.name),
                          Spacer(),
                          Icon(Icons.local_fire_department, color: Colors.orange, size: 12.0,),
                       Text("  ${calculateStreak(board.timePeriod, board.frequency, DateTime.now(), board.entries.map((e) => e.date).toList())}", style: TextStyle(color: Colors.white))
                    ]),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.check,
                        color: board.isDateChecked(DateTime.now())
                            ? Color(0xffFCEE6D)
                            : Colors.grey,
                      ),
                      onPressed: () {
                        context
                            .read<HabitBoardCubit>()
                            .toggleDate(board, DateTime.now());
                      },
                    ),
                    onTap: () {
                      context.read<HabitBoardCubit>().selectBoard(board);
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => ViewBoardPage()));
                    }),
                onDismissed: (direction) async {
                  var cubit = context.read<HabitBoardCubit>();
                  cubit.deleteBoard(board);
                  var closedReason = await Scaffold.of(context)
                      .showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(bottom: 92),
                        content: Text("${board.name} deleted"),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            cubit.undoDeleteBoard(board);
                          },
                        ),
                      ))
                      .closed;

                  if (closedReason != SnackBarClosedReason.action) {
                    cubit.tidyUpDeleteBoard(board);
                  }
                },
              );
              },
            ),
          );
        },
      ),
    );
  }
}
