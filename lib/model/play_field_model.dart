
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:ui';
import 'dart:isolate';

enum shiftDirection
{
  bottom,
  left,
  right
}


enum formFigure
{
  square,
  brokenLine,
  brokenLineMirror,
  straightLine,
  pile,
  lightning,
  lightningMirror
}

class Figure
{
  int mostLeftPixelIndex = 0;
  int mostButtPixelIndex = 0;
  int height = 0;
  int width = 0;
  List<List<int>> active_figure = [[]];

  List<List<int>> Rotate()
  {
    int biggerDimens;
    if(height > width){biggerDimens = height;} else {biggerDimens = width;}
    List<List<List<bool>>> matrix = [];
    for(int i = 0; i < biggerDimens; i++)
    {
      matrix.add([]);
      for(int j = 0; j < biggerDimens; j++)
      {
        matrix[i].add([false, false]);
      }

    }

    int verticalShift =  this.active_figure[mostButtPixelIndex][1];
    int horizontalShift = active_figure[mostLeftPixelIndex][0];

    for(List<int> el in active_figure)
    {
      matrix[el[0] - horizontalShift][(height - (verticalShift - el[1]) - 1)][0] = true;
    }

    List<List<int>> active_figure_buff = [[]];
    var oldMostButtPixelIndex = mostButtPixelIndex;
    var oldMostLeftPixelIndex = mostLeftPixelIndex;

    mostLeftPixelIndex = matrix.length;
    mostButtPixelIndex = 1;
    int mostLeftPixelVal = matrix.length;
    int mostButtPixelVal = 0;
    int pixelCount = 0;

    int buf = height;
    height = width;
    width = buf;
    for (int i = 0; i < matrix.length; i++)
    {
      for(int j = (matrix[i].length - 1); j >= 0; j--)
      {
         matrix[matrix.length - 1 - j][i][1] = matrix[i][j][0];
         if(matrix[matrix[i].length - 1 - j][i][1])
         {
           pixelCount++;

           active_figure_buff.add([matrix[i].length - 1 - j, i]);
           if(mostLeftPixelVal > matrix[i].length - 1 - j){mostLeftPixelIndex = pixelCount; mostLeftPixelVal = matrix[i].length - 1 - j;}
           if(mostButtPixelVal < i){mostButtPixelIndex = pixelCount; mostButtPixelVal = i;}
         }
      }
    }
    active_figure_buff.removeAt(0);
    mostLeftPixelIndex--;
    mostButtPixelIndex--;

    verticalShift = active_figure[oldMostButtPixelIndex][1] - active_figure_buff[mostButtPixelIndex][1];
    horizontalShift = active_figure[oldMostLeftPixelIndex][0] - active_figure_buff[mostLeftPixelIndex][0];


    for (int i = 0; i < active_figure_buff.length; i++)
      {
        active_figure_buff[i][0] = active_figure_buff[i][0] + horizontalShift;
        active_figure_buff[i][1] = active_figure_buff[i][1] + verticalShift;
      }
      return active_figure_buff;
  }
}

class PlayFieldModel extends ChangeNotifier {
  int gameCount = 0;
  formFigure curFigure = formFigure.square;
  int timeInterval = 1000;
  Timer timer = Timer(Duration(milliseconds: 1000), (){});
  int _height;
  int _width;
  List<List<VirtualPixelModel>> field_state = [[]];
  List<List<int>> accumulated_entities = [[]];
  Figure activeFigure = Figure();
  List<List<int>> changed_pixels = [[]];
  static const int _width_index = 0;
  static const int _height_index = 1;

  PlayFieldModel(this._width, this._height)
  {
    field_state = [[VirtualPixelModel(false)]];

    for (int i = 0; i < _width; i++) {
      field_state.add([VirtualPixelModel(false)]);
      for (int j = 0; j < _height - 1; j++) {
        field_state[i].add(VirtualPixelModel(false));
      }
    }
    accumulated_entities = List.empty(growable: true);
    for (int i = 0; i < _height; i++) {
      accumulated_entities.add([]);
    }
    Timer(Duration(milliseconds: 5000),(){setPeriodicMoving();});
  }

  void setPeriodicMoving() async
  {
    this.timer = Timer.periodic(Duration(milliseconds: timeInterval), timerCallBack);
  }

  void timerCallBack (Timer timer) async
  {
    if (activeFigure.active_figure.length <= 1)
    {
      CreateFigure(formFigure.values[Random().nextInt(formFigure.lightningMirror.index)]);
    }
    else ShiftActiveFigure(shiftDirection.bottom);

  }


  VirtualPixelModel getPixelInfo(int width, int height) =>
      field_state[width][height];

  void RotateActiveFigure()
  {
    var nextActiveFigureState = activeFigure.Rotate();
    for(List<int> el in nextActiveFigureState)
    {
        if(field_state[el[_width_index]][el[_height_index]].pixel_key.currentState!.el != "as")
        {
          field_state[el[_width_index]][el[_height_index]].pixel_key.currentState!.el = "as";
          field_state[el[_width_index]][el[_height_index]].pixel_key.currentState!.Update();
        }
        else{field_state[el[_width_index]][el[_height_index]].is_accumulated = true;}
    }
    for(List<int> el in activeFigure.active_figure)
    {
      if(!(field_state[el[_width_index]][el[_height_index]].is_accumulated))
      {
        field_state[el[_width_index]][el[_height_index]].pixel_key.currentState!.el = "qw";
        field_state[el[_width_index]][el[_height_index]].pixel_key.currentState!.Update();
      }
    }
    for(List<int> el in nextActiveFigureState)
    {
      field_state[el[_width_index]][el[_height_index]].is_accumulated = false;
    }
    activeFigure.active_figure = nextActiveFigureState;
  }

  int getRowCount() {
    return this.field_state.first.length;
  }

  int getColumnCount() {
    return this.field_state.length;
  }

  void addColumn() {
    this.field_state.add(List.filled(field_state.first.length,
        VirtualPixelModel(false), growable: true));

    this.notifyListeners();
  }

  void addRow() {
    for (int i = 0; i < field_state.length; i++) {
      field_state[i].add(VirtualPixelModel(false));
    }
  }


  void CreateFigure(formFigure figure)
  {

    switch (figure){

        case formFigure.square:
          activeFigure.active_figure = [
            [_width ~/ 2, 2],
            [_width ~/ 2 + 1, 2],
            [_width ~/ 2, 1],
            [_width ~/ 2 + 1, 1]
            ];
          activeFigure.width = 2;
          activeFigure.height = 2;
          activeFigure.mostLeftPixelIndex = 0;

          break;

        case formFigure.brokenLine:
          activeFigure.active_figure = [
            [_width ~/ 2 + 2, 2],
            [_width ~/ 2 + 1, 1],
            [_width ~/ 2, 1],
            [_width ~/ 2 + 2, 1],
          ];
          activeFigure.width = 3;
          activeFigure.height = 2;
          activeFigure.mostLeftPixelIndex = 2;

          break;

        case formFigure.brokenLineMirror:
          activeFigure.active_figure = [
            [_width ~/ 2, 2],
            [_width ~/ 2 + 1, 2],
            [_width ~/ 2 + 2, 2],
            [_width ~/ 2 + 2, 1]
          ];
          activeFigure.width = 3;
          activeFigure.height = 2;
          activeFigure.mostLeftPixelIndex = 0;

          break;

        case formFigure.straightLine:
          activeFigure.active_figure = [
            [_width ~/ 2, 1],
            [_width ~/ 2 + 1, 1],
            [_width ~/ 2 + 2, 1],
            [_width ~/ 2 + 3, 1]
          ];
          activeFigure.width = 4;
          activeFigure.height = 1;
          activeFigure.mostLeftPixelIndex = 0;

          break;

        case formFigure.pile:
          activeFigure.active_figure = [
            [_width ~/ 2, 2],
            [_width ~/ 2 + 1, 2],
            [_width ~/ 2 + 2, 2],
            [_width ~/ 2 + 1, 1]
          ];
          activeFigure.width = 3;
          activeFigure.height = 2;
          activeFigure.mostLeftPixelIndex = 0;

          break;

      case formFigure.lightning:
        activeFigure.active_figure = [
          [_width ~/ 2 + 2, 2],
          [_width ~/ 2 + 1, 2],
          [_width ~/ 2, 1],
          [_width ~/ 2 + 1, 1],
        ];
        activeFigure.width = 3;
        activeFigure.height = 2;
        activeFigure.mostLeftPixelIndex = 2;

        break;

      case formFigure.lightningMirror:
        activeFigure.active_figure = [
          [_width ~/ 2, 2],
          [_width ~/ 2 + 1, 2],
          [_width ~/ 2 + 1, 1],
          [_width ~/ 2 + 2, 1]
        ];
        activeFigure.width = 3;
        activeFigure.height = 2;
        activeFigure.mostLeftPixelIndex = 0;

        break;
    }
    activeFigure.mostButtPixelIndex = 0;


    for (List<int> el_place in activeFigure.active_figure) {
      field_state[el_place[_width_index]][el_place[_height_index]].pixel_key
          .currentState?.el = "as";
      field_state[el_place[_width_index]][el_place[_height_index]].pixel_key
          .currentState!.Update();
    }
  }

  void accumulate_entitie() {
    while (activeFigure.active_figure.length != 0)
    {
      field_state[activeFigure.active_figure.last[_width_index]][activeFigure.active_figure.last[_height_index]].is_accumulated = true;
      var buf = activeFigure.active_figure.removeLast();
      accumulated_entities[buf[_height_index]].add(buf[_width_index]);
    }
    FlushFullLines();

  }

  void FlushFullLines()
  {
    activeFigure.active_figure = [];
    for (int i = 0; i < _height; i++)
    {
    if(accumulated_entities[i].length == _width)
    {
      for (int j = 0; j < _width; j++)
      {
        field_state[j][i].is_accumulated = false;
        field_state[j][i].pixel_key.currentState!.el = "qw";
        field_state[j][i].pixel_key.currentState!.Update();
      }
      accumulated_entities[i] = [];
      for(int j = (i-1); j >= 0; j--)
      {
        var len = accumulated_entities[j].length;
        for(int k = 0; k < len; k++)
        {
          field_state[accumulated_entities[j].last][j].is_accumulated = false;
          activeFigure.active_figure.add([accumulated_entities[j].removeLast(), j]);
        }
      }
      while(ShiftActiveFigure(shiftDirection.bottom)){}
      gameCount++;
      timeInterval-=20;
      timer.cancel();
      this.timer = Timer.periodic(Duration(milliseconds: timeInterval), timerCallBack);
    }

    }

  }

    bool IsShiftible(shiftDirection dir) {
      List<List<int>> next_el = [];
      List<List<int>> last_el = [];
      var first_el;
      try {
        first_el = activeFigure.active_figure[0];
      } catch (el) {
        return false;
      }
      last_el.add(first_el);

      switch (dir) {
        case shiftDirection.left:
          {
            for (List<int> el in activeFigure.active_figure) {
              if (el[_width_index] - 1 == -1) {
                print("isnt shiftible_left");
                return false;
              }
              else {
                if (field_state[el[_width_index] - 1][el[_height_index]]
                    .is_accumulated) {
                  print("isnt shiftible_left to accum pixels");
                  return false;
                }
              }
            }
            next_el = List.from(last_el);

            break;
          }

        case shiftDirection.right:
          {
            for (List<int> el in activeFigure.active_figure) {
              if (el[_width_index] + 1 == _width) {
                print("isnt shiftible_right");
                return false;
              }
              else {
                if (field_state[el[_width_index] + 1][el[_height_index]]
                    .is_accumulated) {
                  print("isnt shiftible_left to accum pixels");
                  return false;
                }
              }
            }
            next_el = List.from(last_el);

            break;
          }

        case shiftDirection.bottom:
          {
            for (List<int> el in activeFigure.active_figure) {
              if (el[_height_index] + 1 == _height) {
                accumulate_entitie();
                return false;
              }
              else {
                if (field_state[el[_width_index]][(el[_height_index] + 1)]
                    .is_accumulated) {
                  accumulate_entitie();
                  {
                    return false;
                  }
                }
              }
            }
          }
      }

      print("next_el_is_shift: $next_el");
      print("accuM-entities: $accumulated_entities");


      return true;
    }
    bool ShiftActiveFigure(shiftDirection dir)
    {
      if (!IsShiftible(dir)) {return false;}
      var active_figure_buffer = List.from(activeFigure.active_figure, growable: true);
      changed_pixels = [[0, 0]];
      print("$active_figure_buffer");
      List<int> next_el;
      List<int> prev_el;

      var len = active_figure_buffer.length;
      for (int i = 0; i < len; i++)
      {
        next_el = List.from(active_figure_buffer[i]);
        prev_el = List.from(active_figure_buffer[i]);


        switch (dir)
        {
          case shiftDirection.bottom:
            {
              next_el[_height_index] = next_el[_height_index] + 1;
              prev_el[_height_index] = prev_el[_height_index] - 1;
              break;
            }

          case shiftDirection.left:
            {
              next_el[_width_index] = next_el[_width_index] - 1;
              prev_el[_width_index] = prev_el[_width_index] + 1;

              break;
            }

          case shiftDirection.right:
            {
              next_el[_width_index] = next_el[_width_index] + 1;
              prev_el[_width_index] = prev_el[_width_index] - 1;

              break;
            }
        }

        var active_el = active_figure_buffer[i];
        GlobalKey<VirtualPixelState> prev_el_key;
        var next_el_key;
        try {
          prev_el_key =
              field_state[prev_el[_width_index]][prev_el[_height_index]]
                  .pixel_key;
        }
        catch (el) {
          prev_el_key = field_state[0][0].pixel_key;
        }
        try {
          next_el_key =
              field_state[next_el[_width_index]][next_el[_height_index]]
                  .pixel_key;
        }
        catch (el) {
          return false;
        }
        print("i: $i | active_el: $active_el | next_el: $next_el");
        if (next_el_key.currentState.el == "qw") {
          if (prev_el_key.currentState!.el == "qw") {
            changed_pixels.add(next_el);
            changed_pixels.add(active_figure_buffer[i]);
            // break;
          }
          else {
            print("next short. prev active");

            changed_pixels.add(next_el);
          }
        }
        else {
          if (prev_el_key.currentState!.el == "qw" ||
              field_state[prev_el[_width_index]][prev_el[_height_index]]
                  .is_accumulated) {
            print("next active. prev short or hz");
            changed_pixels.add(active_figure_buffer[i]);
          }
          else {}
        }

        active_figure_buffer[i] = next_el;
      }

      while (changed_pixels.length != 1) {
        var el = changed_pixels.removeLast();
        if (field_state[el[_width_index]][el[_height_index]].pixel_key
            .currentState!.el == "qw") {
          field_state[el[_width_index]][el[_height_index]].pixel_key
              .currentState!.el = "as";
        }
        else {
          field_state[el[_width_index]][el[_height_index]].pixel_key
              .currentState!.el = "qw";
        }
        field_state[el[_width_index]][el[_height_index]].pixel_key.currentState!
            .Update();
      }
      activeFigure.active_figure = List.from(active_figure_buffer);
      return true;
    }
  }


class VirtualPixelModel
{
  var is_accumulated = false;
  var pixel_state = false;
  var is_changed  = false;
  GlobalKey<VirtualPixelState> pixel_key = GlobalKey();
  VirtualPixelModel(this.pixel_state,){if(pixel_key == null){pixel_key = GlobalKey();} }
}

class VirtualPixel extends StatefulWidget
{
  VirtualPixel({required Key key,}) : super(key: key);
  static int inst_numb = 0;
  int local_inst_numb = 0;

  @override
  State<StatefulWidget> createState()
  {
    local_inst_numb = inst_numb;
    inst_numb++;
    return VirtualPixelState();
  }
}

class VirtualPixelState extends State<VirtualPixel>
{

  var el = "qw";
  Update(){setState(() {});}

  @override
  Widget build(BuildContext context)
  {

    if (el == "qw"){
    return Container( child: Container(color: Color.fromARGB(200, 40, 40, 40),));}
    else {return Container( child: Container(color: Color.fromARGB(
        178, 78, 0, 161),));}
  }
}
