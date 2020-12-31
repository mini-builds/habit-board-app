import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_board/model.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';

part 'state.g.dart';

@JsonSerializable(nullable: true)
class HabitBoardState {
  final List<Board> boards;
  final Board selectedBoard;

  HabitBoardState(this.boards, this.selectedBoard);

  factory HabitBoardState.fromJson(Map<String, dynamic> json) => _$HabitBoardStateFromJson(json);
  Map<String, dynamic> toJson() => _$HabitBoardStateToJson(this);
}

class HabitBoardCubit extends Cubit<HabitBoardState> {
  List<Tuple2<Board, int>> deletedBoards = List<Tuple2<Board, int>>();

  HabitBoardCubit() : super(HabitBoardState([], null));

  Future<void> loadState() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();

    String appDocPath = appDocDir.path;

    var stateFile = File('$appDocPath/habitboardstate.json');
    var exists = await stateFile.exists();

    if (exists) {
      var stateString = await stateFile.readAsString();
      var state = HabitBoardState.fromJson(jsonDecode(stateString));
      emit(state);
    }
  }

  Future<void> saveState() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();

    String appDocPath = appDocDir.path;

    var stateFile = File('$appDocPath/habitboardstate.json');
    var stateString = jsonEncode(this.state.toJson());

    stateFile.writeAsString(stateString);

    print('Saved state');
  }

  void addBoard(Board board) =>
      emit(HabitBoardState(this.state.boards..add(board), this.state.selectedBoard));

  void editBoard(Board board, String name, TimePeriod timePeriod, int frequency) {
    var index = this.state.boards.indexOf(board);
    var editedBoard = Board(name, board.entries, timePeriod, frequency);
    this.state.boards[index] = editedBoard;
    emit(HabitBoardState(
        this.state.boards, this.state.selectedBoard == board ? editedBoard : this.state.selectedBoard));
  }

  void toggleDate(Board board, DateTime date) {
    board.toggle(date);
    emit(HabitBoardState(this.state.boards, this.state.selectedBoard));
  }

  void selectBoard(Board board) {
    emit(HabitBoardState(this.state.boards, board));
  }

  void deleteBoard(Board board) {
    var index = this.state.boards.indexOf(board);
    if (index != -1) {
      deletedBoards.add(Tuple2(board, index));
      state.boards.removeAt(index);
      emit(HabitBoardState(state.boards, board));
    }
  }

  void undoDeleteBoard(Board board) {
    var index = deletedBoards.indexWhere((t) => t.item1 == board);
    if (index != -1) {
      var t = deletedBoards[index];
      state.boards.insert(t.item2, t.item1);
      emit(HabitBoardState(state.boards, board));
    }
  }

  void tidyUpDeleteBoard(Board board) {
    deletedBoards.removeWhere((t) => t.item1 == board);
  }

}
