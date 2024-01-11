import 'package:flutter/material.dart';
import 'game_controller.dart'; // Ensure this is pointing to your GameController

class TextModeTicTacToe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe Text Mode'),
        backgroundColor: Colors.deepPurple,
      ),
      body: TextModeHome(),
    );
  }
}

class TextModeHome extends StatefulWidget {
  @override
  _TextModeHomeState createState() => _TextModeHomeState();
}

class _TextModeHomeState extends State<TextModeHome> {
  GameController controller = GameController();
  List<String> messages = [];
  TextEditingController textController = TextEditingController();
  FocusNode textFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.loadGame().then((_) {
      setState(() {
        messages.clear();
        if (controller.winner != Player.None) {
          messages.add("Game: Player ${controller.winner} wins!");
        } else if (controller.isGameOver) {
          messages.add("Game: It's a draw!");
        } else {
          messages.add("Game: Player ${controller.currentPlayer} starts. Enter 1-9 to make a move.");
        }
        updateBoardMessage();
      });
    });
    updateBoardMessage();
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      setState(() {
        int? move = int.tryParse(message);
        if (move != null && move >= 1 && move <= 9) {
          // Convert move to row and col
          int row = (move - 1) ~/ 3;
          int col = (move - 1) % 3;
          if (controller.board.getPlayer(row, col) == Player.None) {
            controller.playTurn(row, col);
            updateGameMessages(message);
          } else {
            messages.add("Game: Spot already taken. Try another spot.");
          }
        } else if (message.toUpperCase() == "R") {
          updateGameMessages(message);
        } else {
          messages.add("Game: Invalid move. Enter a number between 1 and 9, or R");
        }
        if (controller.winner == Player.None && controller.isGameOver == false)
          updateBoardMessage();
      });
      textController.clear();
      FocusScope.of(context).requestFocus(textFocusNode);
    }
  }

  void updateGameMessages(String message) {
    if (controller.winner != Player.None) {
      messages.add("Game: Player ${controller.winner} wins!");
      //Asking for restart
      messages.add("Enter R to restart the game");
      if (message == "R") {
        controller.resetGame();
      }
    } else if (controller.isGameOver) {
      messages.add("Game: It's a draw!");
      //Asking for restart
      messages.add("Enter R to restart the game");
      if (message == "R") {
        controller.resetGame();
      }
    } else {
      messages.add("Game: Player ${controller.currentPlayer}'s turn.");
    }
  }

  void updateBoardMessage() {
    List<String> boardRepresentation =
        List.generate(9, (index) => (index + 1).toString());
    for (int i = 0; i < 9; i++) {
      var player = controller.board.getPlayer(i ~/ 3, i % 3);
      if (player != Player.None) {
        boardRepresentation[i] = player == Player.X ? 'X' : 'O';
      }
    }
    messages.add(
        "Game Board:\n${boardRepresentation.sublist(0, 3).join(' | ')}\n${boardRepresentation.sublist(3, 6).join(' | ')}\n${boardRepresentation.sublist(6, 9).join(' | ')}");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              bool isUserMessage = messages[index].startsWith("You:");
              return Container(
                alignment: isUserMessage
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUserMessage ? Colors.blue[200] : Colors.green[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    messages[index],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: textController,
                  focusNode: textFocusNode,
                  onSubmitted: sendMessage,
                  decoration: InputDecoration(
                    hintText: 'Enter 1-9 to make your move...',
                    filled: true,
                    fillColor: Colors.deepPurple[50],
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send, color: Colors.deepPurple),
                onPressed: () => sendMessage(textController.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
