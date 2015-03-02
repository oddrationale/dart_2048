library dart_2048.html_actuator;

import 'dart:html';
import 'src/tile.dart' show Position, Tile;
import 'src/grid.dart' show Grid;

class HTMLActuator {
  DivElement tileContainer = querySelector(".tile-container");
  DivElement scoreContainer = querySelector(".score-container");
  DivElement bestContainer = querySelector(".best-container");
  DivElement messageContainer = querySelector(".game-message");

  int score = 0;

  void actuate(Grid grid, Map metadata) {
    window.requestAnimationFrame((_) {
      clearContainer(tileContainer);

      grid.eachCell((int x, int y, Tile tile) {
        if (tile != null) {
          addTile(tile);
        }
      });

      updateScore(metadata["score"]);
      updateBestScore(metadata["bestScore"]);

      if (metadata["terminated"]) {
        if (metadata["over"]) {
          message(false); // You lose
        } else if (metadata["won"]) {
          message(true); // You win!
        }
      }
    });
  }

  void continueGame() {
    clearMessage();
  }

  void clearContainer(Element container) {
    container.children.clear();
  }

  void addTile(Tile tile) {
    DivElement wrapper = new DivElement();
    DivElement inner = new DivElement();
    Position position =
        (tile.previousPosition != null) ? tile.previousPosition : tile.position;
    String positionClass = this.positionClass(position);

    // We can't use classlist because it somehow glitches when replacing classes
    List<String> classes = ["tile", "tile-${tile.value}", positionClass];

    if (tile.value > 2048) {
      classes.add("tile-super");
    }

    applyClasses(wrapper, classes);

    inner.classes.add("tile-inner");
    inner.text = "${tile.value}";

    if (tile.previousPosition != null) {
      // Make sure that the tile gets rendered in the previous position first
      window.requestAnimationFrame((_) {
        classes[2] = this.positionClass(tile.position);
        applyClasses(wrapper, classes); // Update the position
      });
    } else if (tile.mergedFrom != null) {
      classes.add("tile-merged");
      applyClasses(wrapper, classes);

      // Render the tiles that merged
      tile.mergedFrom.forEach((merged) {
        addTile(merged);
      });
    } else {
      classes.add("tile-new");
      applyClasses(wrapper, classes);
    }

    // Add the inner part of the tile to the wrapper
    wrapper.children.add(inner);

    // Put the tile on the board
    tileContainer.children.add(wrapper);
  }

  void applyClasses(Element element, List<String> classes) {
    element.classes = classes;
  }

  Position normalizePosition(Position position) {
    return new Position(position.x + 1, position.y + 1);
  }

  String positionClass(Position position) {
    position = normalizePosition(position);
    return "tile-position-${position.x}-${position.y}";
  }

  void updateScore(int score) {
    clearContainer(scoreContainer);

    int difference = score - this.score;
    this.score = score;

    scoreContainer.text = "${this.score}";

    if (difference > 0) {
      DivElement addition = new DivElement();
      addition.classes.add("score-addition");
      addition.text = "+${difference}";

      scoreContainer.children.add(addition);
    }
  }

  void updateBestScore(int bestScore) {
    bestContainer.text = "${bestScore}";
  }

  void message(bool won) {
    String type = won ? "game-won" : "game-over";
    String message = won ? "You win!" : "Game over!";

    messageContainer.classes.add(type);
    messageContainer.querySelector("p").text = message;
  }

  void clearMessage() {
    messageContainer.classes.remove("game-won");
    messageContainer.classes.remove("game-over");
  }
}
