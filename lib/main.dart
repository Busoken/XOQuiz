import 'package:flutter/material.dart';
import 'mode_selector.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic-Tac-Toe',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GameModeSelector(),
    );
  }
}
