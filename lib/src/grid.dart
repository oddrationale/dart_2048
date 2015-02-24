import 'dart:math';
import 'tile.dart';

class Grid {
  num size;
  List<List<Tile>> cells;

  // Build a grid of the specified size
  Grid(num size) {
    this.size = size;
    this.cells = new List<List>.filled(size, new List<Tile>(size));
  }

  Grid.fromState(num size, List<List<Tile>> state) {
    this.size = size;
    this.cells = state;
  }

  Grid.fromJson(Map json) {
    this.size = json["size"];
    this.cells = json["cells"];
  }

  // Find the first available random position
  randomAvailableCell() {
    List<Position> availableCells = this.availableCells();

    if (availableCells.length > 0) {
      return availableCells[new Random().nextInt(availableCells.length + 1)];
    }
  }

  List<Position> availableCells() {
    List<Position> availableCells = new List<Position>();

    eachCell((x, y, tile) {
      if (tile == null) {
        availableCells.add(new Position(x, y));
      }
    });

    return availableCells;
  }

  // Call callback for every cell
  void eachCell(Function callback) {
    for (var x = 0; x < size; x++) {
      for (var y = 0; y < size; y++) {
        callback(x, y, cells[x][y]);
      }
    }
  }

  // Check if there are any cells available
  bool cellsAvailable() => availableCells().length > 0;

  // Check if the specified cell is taken
  bool cellAvailable(Position cell) => cellContent(cell) == null;

  bool cellOccupied(Position cell) => cellContent(cell) != null;

  cellContent(Position cell) {
    if (withinBounds(cell)) {
      return cells[cell.x][cell.y];
    } else {
      return null;
    }
  }

  // Inserts a tile at its position
  void insertTile(Tile tile) {
    cells[tile.position.x][tile.position.y] = tile;
  }

  void removeTile(Tile tile) {
    cells[tile.position.x][tile.position.y] = null;
  }

  bool withinBounds(Position position) {
    return position.x >= 0 &&
        position.x < size &&
        position.y >= 0 &&
        position.y < size;
  }

  Map toJson() => {
    "size": size,
    "cells": cells,
  };
}
