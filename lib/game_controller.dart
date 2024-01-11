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
  Future<void> saveGame() async {
    final file = await _localFile;
    Map<String, dynamic> gameState = {
      'board': board.board.map((row) => row.map((e) => e.index).toList()).toList(),
      'currentPlayer': currentPlayer.index,
      'winner': winner.index
    };
    String jsonString = jsonEncode(gameState);
    await file.writeAsString(jsonString);
  }

  Future<void> loadGame() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        Map<String, dynamic> gameState = jsonDecode(jsonString);

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

  // Helper function to get local file for storing game data
  Future<File> get _localFile async {
    final directory = Directory.current; // Getting the current directory
    return File('${directory.path}/gamedata.json'); // Adjusting the path to gamedata.json
  }

  void randomizeStartingPlayer() {
    var random = Random();
    currentPlayer = random.nextBool() ? Player.X : Player.O;
  }

  void playTurn(int row, int col) {
    if (board.getPlayer(row, col) == Player.None && winner == Player.None) {
      board.setPlayer(row, col, currentPlayer);
      saveGame();

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
