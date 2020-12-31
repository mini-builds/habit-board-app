import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_board/model.dart';
import 'package:habit_board/state.dart';

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

  _BoardPageState(Board board) {
    _controller = TextEditingController(text: board == null ? '' : board.name);
    _frequencyController =
        TextEditingController(text: board == null ? '1' : board.frequency.toString());
    _timePeriod = board == null ? TimePeriod.day : board.timePeriod;
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
                        context.read<HabitBoardCubit>().addBoard(Board(
                            _controller.text, [], _timePeriod, _timePeriod == TimePeriod.day ? 1 : int.parse(_frequencyController.text)));
                      } else {
                        context.read<HabitBoardCubit>().editBoard(widget.board, _controller.text,
                            _timePeriod, _timePeriod == TimePeriod.day ? 1 : int.parse(_frequencyController.text));
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
              ],
            ),
          );
        },
      ),
    );
  }
}
