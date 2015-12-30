library dart_2048.grid;

import 'dart:math' show Random;
import 'tile.dart' show Position, Tile;

class Grid {
  int size;
  List<List<Tile>> cells;

  // Build a grid of the specified size
  Grid(int size) {
    this.size = size;
    this.cells = new List<List>.generate(size, (_) => new List<Tile>(size));
  }

  Grid.fromState(int size, List<List<Tile>> state) {
    this.size = size;
    this.cells = state;
  }

  Grid.fromJson(Map<String, dynamic> json) {
    this.size = json["size"];
    this.cells = json["cells"];
  }

  // Find the first available random position
  Position randomAvailableCell() {
    List<Position> availableCells = this.availableCells();

    if (availableCells.length == 0) {
      return null;
    }
    return availableCells[new Random().nextInt(availableCells.length)];
  }

  List<Position> availableCells() {
    List<Position> availableCells = new List<Position>();

    eachCell((int x, int y, Tile tile) {
      if (tile == null) {
        availableCells.add(new Position(x, y));
      }
    });

    return availableCells;
  }

  // Call callback for every cell
  void eachCell(void callback(int x, int y, Tile tile)) {
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        callback(x, y, cells[x][y]);
      }
    }
  }

  // Check if there are any cells available
  bool cellsAvailable() => availableCells().length > 0;

  // Check if the specified cell is taken
  bool cellAvailable(Position cell) => cellContent(cell) == null;

  bool cellOccupied(Position cell) => cellContent(cell) != null;

  Tile cellContent(Position cell) {
    if (!withinBounds(cell)) {
      return null;
    }
    return cells[cell.x][cell.y];
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

  Map<String, dynamic> toJson() => {"size": size, "cells": cells};
}
