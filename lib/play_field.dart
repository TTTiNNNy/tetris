import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tetris/model/play_field_model.dart';
import 'package:tetris/play_field.dart';


class PlayForm extends StatefulWidget
{
  PlayFieldModel field_model = new PlayFieldModel(PlayForm.width, PlayForm.height);

  static const  width = 10;
  static const height = 15;
  PlayForm({Key key,}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PlayField();
}

class PlayField extends State<PlayForm>
{

  GlobalKey last_key = GlobalKey();
  int _count = 0;
  StatefulWidget wg ;

  @override
  Widget build(BuildContext context)
  {

    const double _padding = 10;
    return Column
       (

          children:
          [
            //Text("qwert"),
            Expanded( child:
            GridView.builder
            (
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount
              (
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                crossAxisCount: PlayForm.width
              ),
              itemCount: PlayForm.width * PlayForm.height,
              itemBuilder: (BuildContext ctx, index)
              {
                int height_index = (index / PlayForm.width).truncate().toInt();
                int width_index   = index % PlayForm.width;
                print ("index_build: $index");
                 GlobalKey<VirtualPixelState> key = new GlobalKey();                         /// работает
                 widget.field_model.field_state[width_index][height_index].pixel_key = key;  ///
                var cont = VirtualPixel(key: key,);                                          ///
                return cont;
              }
            )),//,

            GamePanelControl(this.widget.field_model)
  ]
    );
      // );
  }

}



class GamePanelControl extends StatelessWidget
{
  final PlayFieldModel panel;
  GamePanelControl(this.panel);

  @override
  Widget build(BuildContext context)
  {
    return Row
      (
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
      [

        IconButton(onPressed: () {panel.ShiftActiveFigure(shiftDirection.left);}, icon: Icon(Icons.keyboard_arrow_left), ),
        IconButton(onPressed: () {panel.ShiftActiveFigure(shiftDirection.right);}, icon: Icon(Icons.keyboard_arrow_right),),
        IconButton(onPressed: () {panel.ShiftActiveFigure(shiftDirection.bottom);}, icon: Icon(Icons.keyboard_arrow_down),),
        Container (child: IconButton (onPressed: () { panel.CreateRect(); },icon: Icon(Icons.refresh))),
        Container(height: 20,child: Text("0")),
      ],
    );
  }



}