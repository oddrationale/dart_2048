class Position {
  num x, y;

  Position(this.x, this.y);

  Position.fromJson(Map json) {
    x = json["x"];
    y = json["y"];
  }

  Map toJson() => {
    "x": x,
    "y": y,
  };
}

class Tile {
  Position position, previousPosition;
  num value = 2;
  var mergedFrom;

  Tile(this.position, this.value);

  Tile.fromJson(Map json) {
    position = json["position"];
    value = json["value"];
  }

  void savePosition() {
    previousPosition = position;
  }

  void updatePosition(Position position) {
    this.position = position;
  }

  Map toJson() => {
    "position": position,
    "value": value,
  };
}
