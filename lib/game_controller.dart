import 'dart:io';
import 'dart:convert'; // For converting data to JSON format
import 'dart:math';

enum Player { X, O, None }

class GameBoard {
  late List<List<Player>> board;

  GameBoard() {
    resetBoard();
  }

  void resetBoard() {
    board = List.generate(3, (_) => List.generate(3, (_) => Player.None));
  }

  Player getPlayer(int row, int col) {
    return board[row][col];
  }

  void setPlayer(int row, int col, Player player) {
    if (board[row][col] == Player.None) {
      board[row][col] = player;
    }
  }

  bool isFull() {
    return board.every((row) => row.every((cell) => cell != Player.None));
  }
}

class GameController {
  late GameBoard board;
  Player currentPlayer = Player.X;
  Player winner = Player.None;

  GameController() {
    board = GameBoard();
    currentPlayer; // Default starting player
    winner;
  }
  Future<void> saveGame({bool textfile = false}) async {
    final file = await _localFile(textfile);
    Map<String, dynamic> gameState = {
      'board': board.board.map((row) => row.map((e) => e.index).toList()).toList(),
      'currentPlayer': currentPlayer.index,
      'winner': winner.index
    };

    if (textfile) {
      // Save in a custom text format
      String textData = gameStateToString(gameState);
      await file.writeAsString(textData);
    } else {
      // Save in JSON format
      String jsonString = jsonEncode(gameState);
      await file.writeAsString(jsonString);
    }
  }

  // Custom method to convert gameState to a String for text file format
String gameStateToString(Map<String, dynamic> gameState) {
  // Convert the gameState object to a string representation
  // Example format: "0,1,2\n1,1,0\n0,2,1\n[currentPlayerIndex]\n[winnerIndex]"

  var boardRows = gameState['board']
      .map((row) => row.map((e) => e.toString()).join(','))
      .join('\n');

  return '$boardRows\n${gameState['currentPlayer']}\n${gameState['winner']}';
}


  Future<void> loadGame({bool textfile = false}) async {
    try {
      final file = await _localFile(textfile);
      if (await file.exists()) {
        Map<String, dynamic> gameState;

        if (textfile) {
          // Load from a custom text format
          String textData = await file.readAsString();
          gameState = stringToGameState(textData);
        } else {
          // Load from JSON format
          String jsonString = await file.readAsString();
          gameState = jsonDecode(jsonString);
        }

        // Updating the game state from the loaded data
        board.board = List.generate(
          3,
          (i) => List.generate(
              3,
              (j) => Player.values[gameState['board'][i][j]],
              growable: false),
          growable: false);

        currentPlayer = Player.values[gameState['currentPlayer']];
        winner = Player.values[gameState['winner']];
      }
    } catch (e) {
      // If encountering an error, default the game state
      resetGame();
    }
  }

  // Custom method to convert a String from a text file to gameState
Map<String, dynamic> stringToGameState(String textData) {
  // Assuming format: "0,1,2\n1,1,0\n0,2,1\n[currentPlayerIndex]\n[winnerIndex]"
  var lines = textData.split('\n');

  if (lines.length < 5) {
    // Handle error or return a default state if the format is not as expected
    // You can throw an exception or return a default game state
  }

  var boardData = List.generate(
    3,
    (i) => lines[i]
            .split(',')
            .map((e) => int.tryParse(e) ?? 0)
            .toList(),
    growable: false);

  var currentPlayer = int.tryParse(lines[3]) ?? 0;
  var winner = int.tryParse(lines[4]) ?? 0;

  return {
    'board': boardData,
    'currentPlayer': currentPlayer,
    'winner': winner,
  };
}


  // Helper function to get local file for storing game data
  Future<File> _localFile(bool textfile) async {
    final directory = Directory.current; // Getting the current directory
    return File('${directory.path}/gamedata.${textfile ? 'txt' : 'json'}'); // Choose file extension based on 'textfile' boolean
  }

  void randomizeStartingPlayer() {
    var random = Random();
    currentPlayer = random.nextBool() ? Player.X : Player.O;
  }

  void playTurn(int row, int col) {
    if (board.getPlayer(row, col) == Player.None && winner == Player.None) {
      board.setPlayer(row, col, currentPlayer);
      saveGame(textfile: true);

      if (checkWinner(row, col)) {
        winner = currentPlayer;
      } else {
        currentPlayer = currentPlayer == Player.X ? Player.O : Player.X;
      }
    }
  }


  bool checkWinner(int row, int col) {
    // Check row
    if (board.board[row][0] == currentPlayer &&
        board.board[row][1] == currentPlayer &&
        board.board[row][2] == currentPlayer) {
      return true;
    }

    // Check column
    if (board.board[0][col] == currentPlayer &&
        board.board[1][col] == currentPlayer &&
        board.board[2][col] == currentPlayer) {
      return true;
    }

    // Check diagonal
    if (row == col) {
      // Top-left to bottom-right
      if (board.board[0][0] == currentPlayer &&
          board.board[1][1] == currentPlayer &&
          board.board[2][2] == currentPlayer) {
        return true;
      }
    }

    if (row + col == 2) {
      // Top-right to bottom-left
      if (board.board[0][2] == currentPlayer &&
          board.board[1][1] == currentPlayer &&
          board.board[2][0] == currentPlayer) {
        return true;
      }
    }

    return false;
  }
  bool get isGameOver {
    return winner != Player.None || board.isFull();
  }

  void resetGame() {
    board.resetBoard();
    currentPlayer = Player.X;
    winner = Player.None;
    saveGame();
  }
}
