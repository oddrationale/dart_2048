library dart_2048.local_storage_manager;

import 'dart:convert' show JSON;
import 'dart:html';
import 'src/grid.dart' show Grid;
import 'src/tile.dart' show Position, Tile;

class LocalStorageManager {
  String bestScoreKey = "bestScore";
  String gameStateKey = "gameState";

  Storage storage = window.localStorage;

  // Best score getters/setters
  int getBestScore() {
    return (storage[bestScoreKey] != null)
        ? num.parse(storage[bestScoreKey])
        : 0;
  }

  void setBestScore(int score) {
    storage[bestScoreKey] = "${score}";
  }

  // Game state getters/setters and clearing
  Map getGameState() {
    String stateJSON = storage[gameStateKey];
    if (stateJSON == null) {
      return null;
    }
    return JSON.decode(stateJSON, reviver: (key, value) {
      if (key == 'position') {
        return new Position.fromJson(value);
      } else if (key is int && value is Map) {
        return new Tile.fromJson(value);
      } else if (key == 'grid') {
        return new Grid.fromJson(value);
      } else {
        return value;
      }
    });
  }

  void setGameState(Map<String, dynamic> gameState) {
    storage[gameStateKey] = JSON.encode(gameState);
  }

  void clearGameState() {
    storage.remove(gameStateKey);
  }
}
