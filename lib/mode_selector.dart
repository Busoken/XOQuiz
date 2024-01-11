import 'package:flutter/material.dart';
import 'textmode.dart'; // Ensure this file defines TextModeTicTacToe
import 'graphicmode.dart'; // Ensure this file defines GraphicModeTicTacToe

class GameModeSelector extends StatefulWidget {
  @override
  _GameModeSelectorState createState() => _GameModeSelectorState();
}

class _GameModeSelectorState extends State<GameModeSelector> {
  bool isTextMode = true; // Default to text mode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Game Mode')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Switch(
              value: isTextMode,
              onChanged: (value) => setState(() => isTextMode = value),
            ),
            Text(isTextMode ? 'Text Mode' : 'Graphic Mode'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        isTextMode ? TextModeTicTacToe() : GraphicModeTicTacToe(), // Ensure these classes exist and are imported
                  ),
                );
              },
              child: Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}
