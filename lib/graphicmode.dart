import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_controller.dart'; // Ensure this import points to your GameController class

class GraphicModeTicTacToe extends StatefulWidget {
  @override
  _GraphicModeTicTacToeState createState() => _GraphicModeTicTacToeState();
}

class _GraphicModeTicTacToeState extends State<GraphicModeTicTacToe> {
  late GameController controller;

  @override
  void initState() {
    super.initState();
    controller = GameController();
    controller.loadGame().then((_) {
      setState(() {
        controller.randomizeStartingPlayer();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double cellSize = MediaQuery.of(context).size.width / 3;
    double maxCellSize = 90.0; // Reduced max size for smaller cells
    cellSize = cellSize > maxCellSize ? maxCellSize : cellSize;

    return Scaffold(
      appBar: AppBar(
        title: Text('Graphic Mode Tic-Tac-Toe - Player ${controller.currentPlayer.toString().split('.').last}\'s Turn'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // Changed to a deep purple color
      ),
      body: Stack(
        children: [
          Center( // Centered the grid for better aesthetics
            child: Container(
              width: cellSize * 3, // Width for all three cells together
              height: cellSize * 3, // Height for all three cells together
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(), // Disables scrolling for the grid
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1, // Ensures cells are square
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  int row = index ~/ 3;
                  int col = index % 3;
                  return InkWell(
                    onTap: () => _onTileTapped(row, col),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: Colors.grey[300], // Light grey color for cells
                      ),
                      child: Center(
                        child: _buildPlayerSymbol(controller.board.getPlayer(row, col)), // Custom method for player symbols
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (controller.isGameOver) _buildGameOverOverlay(), // This will show the overlay when game is over
        ],
      ),
      floatingActionButton: FloatingActionButton( // Reset game button
        onPressed: () {
          setState(() {
            controller.Undomove();
          });
        },
        child: Icon(Icons.refresh),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void _onTileTapped(int row, int col) {
    if (!controller.isGameOver && controller.board.getPlayer(row, col) == Player.None) {
      setState(() {
        controller.playTurn(row, col);
      });
    }
  }

  Widget _buildPlayerSymbol(Player player) {
    String symbol = '';
    Color color;
    switch (player) {
      case Player.O:
        symbol = 'O';
        color = Colors.red;
        break;
      case Player.X:
        symbol = 'X';
        color = Colors.blue;
        break;
      default:
        symbol = '';
        color = Colors.transparent; // No color for empty cell
    }
    return Text(
      symbol,
      style: TextStyle(fontSize: 40, color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildGameOverOverlay() {
    String message;
    if (controller.winner != Player.None) {
      message = 'Player ${controller.winner.toString().split('.').last} Wins!';
    } else if (controller.isGameOver) {
      message = 'Game is a Draw!';
    } else {
      return SizedBox.shrink(); // Return an empty widget if the game isn't over
    }

    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Game Over',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Text(
              message,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  controller.resetGame();
                });
              },
              child: Text('Restart Game'),
            ),
          ],
        ),
      ),
    );
  }
}
