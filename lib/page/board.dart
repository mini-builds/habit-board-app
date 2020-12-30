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
  TextEditingController controller;
  TimePeriod timePeriod;
  TextEditingController frequencyController;
  var error;

  _BoardPageState(Board board) {
    controller = TextEditingController(text: board == null ? '' : board.name);
    frequencyController = TextEditingController(text: board == null ? '1' : board.frequency.toString());
    timePeriod = board == null ? TimePeriod.day : board.timePeriod;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.board == null ? 'Create a Board' : 'Edit ${widget.board.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: this.error != null
                ? null
                : () {
                    if (widget.board == null) {
                      context.read<HabitBoardCubit>().addBoard(Board(controller.text, [], timePeriod, int.parse(frequencyController.text)));
                    } else {
                      context.read<HabitBoardCubit>().editBoard(widget.board, controller.text, timePeriod, int.parse(frequencyController.text));
                    }
                    Navigator.pop(context);
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
                  decoration: InputDecoration(hintText: 'Name', errorText: this.error, floatingLabelBehavior: FloatingLabelBehavior.never, hintStyle: TextStyle(color: Colors.white60)),
                  controller: controller,
                  onChanged: (v) {
                    setState(() {
                      if (state.boards.any((element) =>
                          element.name.toLowerCase() == v.toLowerCase() && element != widget.board)) {
                        this.error = 'A board with name $v already exists.';
                      } else {
                        this.error = null;
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
                      value: timePeriod,
                      underline: Container(),
                      dropdownColor: Color(0xff25282F),
                      items: TimePeriod.values.map((tp) => DropdownMenuItem<TimePeriod>(
                            value: tp,
                            child: Text(tp.toString().replaceAll('TimePeriod.', ''), style: TextStyle(color: Colors.white),),
                          )).toList(),
                      onChanged: (v) {
                        setState(() {
                          timePeriod = v;
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Frequency'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Frequency', floatingLabelBehavior: FloatingLabelBehavior.never),
                  controller: frequencyController,
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    if (timePeriod == TimePeriod.day) {
                      frequencyController.text = '1';
                    }

                    var freq = int.parse(v);
                    if (timePeriod == TimePeriod.week) {
                      if (freq < 1) {
                        frequencyController.text = '1';
                      }
                      if (freq > 7) {
                        frequencyController.text = '7';
                      }
                    }

                    if (timePeriod == TimePeriod.month) {
                      if (freq < 1) {
                        frequencyController.text = '1';
                      }
                      if (freq > 31) {
                        frequencyController.text = '31';
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
