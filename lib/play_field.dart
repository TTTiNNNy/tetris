import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PlayForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PlayField();
}

class PlayField extends State
{
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
            Expanded( child:
            GridView.builder
            (
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount
              (
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                crossAxisCount: 10
              ),
              itemCount: 150,
              itemBuilder: (BuildContext ctx, index)
              {
                return Container
                (

                 alignment: Alignment.center,
                 child: this.wg,
                 decoration: BoxDecoration(
                 color: Colors.black54,
                 borderRadius: BorderRadius.circular(5)),
                );
              }
            )),//,
             Row
              (
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                [

                  Container (child: IconButton(onPressed: () {setState((){ this._count++; if (this._count % 2 == 0){this.wg = TextButton(onPressed: null, child: Text("qwe"));}else{this.wg = TextButton(child: Text("asd")) as StatefulWidget;}});}, icon: Icon(Icons.keyboard_arrow_left), )),
                  IconButton(onPressed: () {setState((){ this._count--;});}, icon: Icon(Icons.keyboard_arrow_right),),
                  IconButton(onPressed: () {this.wg = TextButton(onPressed: null, child: Text("zxc")); this.build(context);}, icon: Icon(Icons.keyboard_arrow_down),),
                  Container (child: IconButton(onPressed: () {},icon: Icon(Icons.refresh),  ))
                ],
              ),
            Container(height: 20,child: Text("${this._count}"),),
          ],

    );
      // );
  }

}

