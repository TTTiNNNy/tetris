import 'package:flutter/material.dart';
import 'package:tetris/play_field.dart';

import 'theme.dart';


void main() => {
  runApp
  (
    new MaterialApp
      (
        debugShowCheckedModeBanner: false,
        //theme: myTheme,
        home: new Scaffold
          (
            appBar: new AppBar(title: new Text('Tetris')),
            body: new PlayForm(key: GlobalKey(),),
          )
      )
  )

};

// void main() {
//   runApp(
//     MaterialApp(
//       color: Colors.black,
//       home: Scaffold(
//         backgroundColor: Colors.black,
//       ),
//     ),
//   );
// }