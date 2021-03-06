
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:ui';
import 'dart:isolate';

enum shiftDirection { bottom, top, left, right }



class PlayFieldModel extends ChangeNotifier
{
  int _height;
  int _width;
  List<List<VirtualPixelModel>> field_state;
  List<List<int>> active_figure;
  List<List<int>> changed_pixels = [];
  static const int _width_index = 0;
  static const int _height_index = 1;

  PlayFieldModel(this._width, this._height,{Key key})
  {


    //field_state = List.filled(_width, List.filled(_height, VirtualPixelModel(false), growable: true), growable: true);
    //field_state = [[]];
    field_state = [[VirtualPixelModel(false)]];

   // // print("widht: $_width height: $_height");
     for(int i = 0; i < _width; i++)
     {
       field_state.add([VirtualPixelModel(false)]);
       for (int j = 0; j < _height-1; j++)
       {
        print("j = $j, i = $i");
         field_state[i].add(VirtualPixelModel(false));

         //print(" $_field_state[i][j].pixel_key.hashCode ");
       }
     }
  }

  VirtualPixelModel getPixelInfo(int width, int height) => field_state[width][height];

  int getRowCount()
  {
    return this.field_state.first.length;
  }
  int getColumnCount()
  {
    return this.field_state.length;
  }
  void addColumn()
  {
    this.field_state.add(List.filled(field_state.first.length, VirtualPixelModel(false, pixel_key: GlobalKey()), growable: true));

    this.notifyListeners();
  }
  void addRow()
  {
    for (int i = 0; i < field_state.length; i++)
    {
      field_state[i].add(VirtualPixelModel(false, pixel_key: GlobalKey()));
    }
  }


  void CreateRect()
  {

    active_figure = [[_width~/2, 2], [_width~/2+1, 2], [_width~/2, 1], [_width~/2+1, 1]];
    for (List<int> el_place in active_figure)
    {
      field_state[el_place[_width_index]][el_place[_height_index]].pixel_key.currentState.el = "as";
      field_state[el_place[_width_index]][el_place[_height_index]].pixel_key.currentState.Update();
    }
    print("active_figure: $active_figure");
    print("changed_pixels: $changed_pixels");

  }

  void ShiftActiveFigure(shiftDirection dir)
  {
    var active_figure_buffer = List.from(active_figure, growable: true);
    changed_pixels = [[0,0]];
    print("$active_figure_buffer");
    //changed_pixels = List.filled(0, [0,0], growable: true);
    List<int> next_el;
    List<int> prev_el;

    for (int i = 0; i < active_figure_buffer.length; i++)
    {

        next_el = List.from(active_figure_buffer[i]);
        prev_el = List.from(active_figure_buffer[i]);


      switch (dir)
      {
          case shiftDirection.top:
          {
            next_el[_height_index] = next_el[_height_index] - 1;
            prev_el[_height_index] = prev_el[_height_index] + 1;

            break;
          }

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
            var x = next_el[_width_index];
            var y = next_el[_width_index] + 1;
            print("EVENT");
            print("el = $x | next_el = $y");

            print("before $next_el");
            next_el[_width_index] = next_el[_width_index] + 1;
            print("after $next_el");
            prev_el[_width_index] = prev_el[_width_index] - 1;

            break;
          }
      }

        var active_el = active_figure_buffer[i];
        GlobalKey<VirtualPixelState> prev_el_key;
        var next_el_key;
        try {prev_el_key = field_state[prev_el[_width_index]][prev_el[_height_index]].pixel_key;}
        catch(el){prev_el_key = field_state[0][0].pixel_key;}
        try{next_el_key = field_state[next_el[_width_index]][next_el[_height_index]].pixel_key;}
        catch(el){ return null;}
        print("i: $i | active_el: $active_el | next_el: $next_el");
        if(next_el_key.currentState.el == "qw")
        {
          if(prev_el_key.currentState.el == "qw")
          {
            changed_pixels.add(next_el);
            changed_pixels.add(active_figure_buffer[i]);
            break;
          }
          else
          {
            changed_pixels.add(next_el);
          }
        }
        else
        {
          if(prev_el_key.currentState.el == "qw")
          {
            changed_pixels.add(active_figure_buffer[i]);
          }
          else {}
        }


        active_figure_buffer[i] = next_el;

      var x = field_state[active_el[_width_index]][active_el[_height_index]].pixel_key.currentState.el;
      var y = field_state[next_el[_width_index]][next_el[_height_index]].pixel_key.currentState.el;
      print("x: $x");
      print("y: $y");

      print("changed_pixels: $changed_pixels");
      print("next_el: $next_el active_figure: $active_figure_buffer");

    }

      while (changed_pixels.length != 1)
    {
      var el = changed_pixels.removeLast();
      if(field_state[el[_width_index]][el[_height_index]].pixel_key.currentState.el == "qw")
      {field_state[el[_width_index]][el[_height_index]].pixel_key.currentState.el = "as";}
      else{field_state[el[_width_index]][el[_height_index]].pixel_key.currentState.el = "qw";}
        field_state[el[_width_index]][el[_height_index]].pixel_key.currentState.Update();
    }
    active_figure = List.from(active_figure_buffer);
  }
}

class VirtualPixelModel
{

  var pixel_state = false;
  var is_changed  = false;
  GlobalKey<VirtualPixelState> pixel_key;
  VirtualPixelModel(this.pixel_state,{this.pixel_key}){if(pixel_key == null){pixel_key = GlobalKey();} }
}

class VirtualPixel extends StatefulWidget
{
  VirtualPixel({Key key,}) : super(key: key){}
  static int inst_numb = 0;
  int local_inst_numb;

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
  Update(){setState(() {
  });}

  @override
  Widget build(BuildContext context)
  {
    if (el == "qw"){
    return Container( child: Container(color: Color.fromARGB(200, 40, 40, 40),));}
    else {return Container( child: Container(color: Color.fromARGB(200, 120, 120, 120),));}
  }
}
