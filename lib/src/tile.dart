library dart_2048.tile;

class Position {
  int x, y;

  Position(this.x, this.y);

  Position.fromJson(Map<String, num> json) {
    x = json["x"];
    y = json["y"];
  }

  Map<String, num> toJson() => {
        "x": x,
        "y": y,
      };
}

class Tile {
  Position position, previousPosition;
  int value = 2;
  List<Tile> mergedFrom;

  Tile(this.position, this.value);

  Tile.fromJson(Map<String, dynamic> json) {
    position = json["position"];
    value = json["value"];
  }

  void savePosition() {
    previousPosition = new Position(position.x, position.y);
  }

  void updatePosition(Position position) {
    this.position = position;
  }

  Map<String, dynamic> toJson() => {
        "position": position,
        "value": value,
      };
}
