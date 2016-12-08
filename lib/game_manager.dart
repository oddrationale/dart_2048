library dart_2048.game_manager;

import 'dart:math';
import 'package:dart_2048/html_actuator.dart';
import 'package:dart_2048/keyboard_input_manager.dart';
import 'package:dart_2048/local_storage_manager.dart';
import 'src/grid.dart';
import 'src/tile.dart';

class GameManager {
  int size = 4; // Size of the grid
  int startTiles = 2;

  Grid grid;
  int score = 0;
  bool over = false;
  bool won = false;
  bool keepPlaying = false;

  KeyboardInputManager inputManager = new KeyboardInputManager();
  LocalStorageManager storageManager = new LocalStorageManager();
  HTMLActuator actuator = new HTMLActuator();

  GameManager(size) {
    this.size = size;

    inputManager
      ..onMove(move)
      ..onRestart(restart)
      ..onKeepPlaying(continuePlaying);

    setup();
  }

  // Restart the game
  void restart() {
    storageManager.clearGameState();
    actuator.continueGame(); // Clear the game won/lost message
    setup();
  }

  // Keep playing after winning (allows going over 2048)
  void continuePlaying() {
    keepPlaying = true;
    actuator.continueGame(); // Clear the game won/lost message
  }

  // Check if game is terminated
  bool isGameTerminated() => over || (won && !keepPlaying);

  // Set up the game
  void setup() {
    Map previousState = storageManager.getGameState();

    // Reload the game from a previous game if present
    if (previousState != null) {
      grid = previousState['grid'];
      score = previousState['score'];
      over = previousState['over'];
      won = previousState['won'];
      keepPlaying = previousState['keepPlaying'];
    } else {
      grid = new Grid(size);
      score = 0;
      over = false;
      won = false;
      keepPlaying = false;

      // Add the initial tiles
      addStartTiles();
    }

    // Update the actuator
    actuate();
  }

  void addStartTiles() {
    for (int i = 0; i < startTiles; i++) {
      addRandomTile();
    }
  }

  void addRandomTile() {
    if (grid.cellsAvailable()) {
      int value = (new Random().nextDouble() < 0.9) ? 2 : 4;
      Tile tile = new Tile(grid.randomAvailableCell(), value);

      grid.insertTile(tile);
    }
  }

  // Sends the updated grid to the actuator
  void actuate() {
    if (storageManager.getBestScore() < score) {
      storageManager.setBestScore(score);
    }

    // Clear the state when the game is over (game over only, not win)
    if (over) {
      storageManager.clearGameState();
    } else {
      storageManager.setGameState(toJson());
    }

    actuator.actuate(grid, {
      'score': score,
      'over': over,
      'won': won,
      'bestScore': storageManager.getBestScore(),
      'terminated': isGameTerminated(),
    });
  }

  Map<String, dynamic> toJson() => {
        'grid': grid,
        'score': score,
        'over': over,
        'won': won,
        'keepPlaying': keepPlaying,
      };

  // Save all tile positions and remove merger info
  void prepareTiles() {
    grid.eachCell((int x, int y, Tile tile) {
      if (tile != null) {
        tile.mergedFrom = null;
        tile.savePosition();
      }
    });
  }

  // Move a tile and its representation
  void moveTile(Tile tile, Position cell) {
    grid.cells[tile.position.x][tile.position.y] = null;
    grid.cells[cell.x][cell.y] = tile;
    tile.updatePosition(cell);
  }

  // Move tiles on the grid in the specified direction
  void move(int direction) {
    // 0: up, 1: right, 2: down, 3: left
    if (isGameTerminated()) return; // Don't do anything if the game's over

    Position cell;
    Tile tile;

    Position vector = getVector(direction);
    Map<String, List<num>> traversals = buildTraversals(vector);
    bool moved = false;

    // Save the current tile positions and remove merger information
    prepareTiles();

    // Traverse the grid in the right direction and move tiles
    traversals['x'].forEach((int x) {
      traversals['y'].forEach((int y) {
        cell = new Position(x, y);
        tile = grid.cellContent(cell);

        if (tile != null) {
          Map<String, Position> positions = findFarthestPosition(cell, vector);
          Tile next = grid.cellContent(positions['next']);

          // Only one merger per row traversal?
          if (next != null &&
              next.value == tile.value &&
              next.mergedFrom == null) {
            Tile merged = new Tile(positions['next'], tile.value * 2);
            merged.mergedFrom = [tile, next];

            grid.insertTile(merged);
            grid.removeTile(tile);

            // Converge the two tiles' positions
            tile.updatePosition(positions['next']);

            // Update the score
            score += merged.value;

            // The mighty 2048 tile
            if (merged.value == 2048) won = true;
          } else {
            moveTile(tile, positions['farthest']);
          }

          if (!positionsEqual(cell, tile)) {
            moved = true; // The tile moved from its original cell!
          }
        }
      });
    });

    if (moved) {
      addRandomTile();

      if (!movesAvailable()) {
        over = true; // Game over!
      }

      actuate();
    }
  }

  // Get the vector representing the chosen direction
  Position getVector(int direction) {
    // Vectors representing tile movement
    Map<num, Position> map = {
      0: new Position(0, -1), // Up
      1: new Position(1, 0), // Right
      2: new Position(0, 1), // Down
      3: new Position(-1, 0), // Left
    };

    return map[direction];
  }

  // Build a list of positions to traverse in the right order
  Map<String, List<num>> buildTraversals(Position vector) {
    Map<String, List<num>> traversals = {
      'x': [],
      'y': [],
    };

    for (int pos = 0; pos < size; pos++) {
      traversals['x'].add(pos);
      traversals['y'].add(pos);
    }

    // Always traverse from the farthest cell in the chosen direction
    if (vector.x == 1) traversals['x'] = traversals['x'].reversed;
    if (vector.y == 1) traversals['y'] = traversals['y'].reversed;

    return traversals;
  }

  Map<String, Position> findFarthestPosition(Position cell, Position vector) {
    Position previous;

    // Progress towards the vector direction until an obstacle is found
    do {
      previous = cell;
      cell = new Position(previous.x + vector.x, previous.y + vector.y);
    } while (grid.withinBounds(cell) && grid.cellAvailable(cell));

    return {
      'farthest': previous,
      'next': cell, // Used to check if a merge is required
    };
  }

  bool movesAvailable() => grid.cellsAvailable() || tileMatchesAvailable();

  // Check for available matches between tiles (more expensive check)
  bool tileMatchesAvailable() {
    Tile tile;

    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        tile = grid.cellContent(new Position(x, y));

        if (tile != null) {
          for (int direction = 0; direction < 4; direction++) {
            Position vector = getVector(direction);
            Position cell = new Position(x + vector.x, y + vector.y);

            Tile other = grid.cellContent(cell);

            if (other != null && other.value == tile.value) {
              return true; // These two tiles can be merged
            }
          }
        }
      }
    }

    return false;
  }

  bool positionsEqual(Position first, Tile second) {
    return first.x == second.position.x && first.y == second.position.y;
  }
}
