import 'dart:html';

class KeyboardInputManager {

  KeyboardInputManager() {
    this.listen();
  }

  void listen() {
    Map<int, int> map = {
      KeyCode.UP: 0,
      KeyCode.RIGHT: 1,
      KeyCode.DOWN: 2,
      KeyCode.LEFT: 3,
      KeyCode.K: 0, // Vim up
      KeyCode.L: 1, // Vim right
      KeyCode.J: 2, // Vim down
      KeyCode.H: 3, // Vim left
      KeyCode.W: 0,
      KeyCode.D: 1,
      KeyCode.S: 2,
      KeyCode.A: 3,
    };

    // Respond to direction keys
    document.onKeyDown.listen((KeyboardEvent event) {
      bool modifiers = event.altKey || event.ctrlKey || event.metaKey || event.shiftKey;
      int mapped = map[event.which];

      if (!modifiers && mapped != null) {
        event.preventDefault();
        print(mapped);
      }

      // R key restarts the game
      if (!modifiers && event.which == KeyCode.R) {
        print("restart");
      }
    });
  }
}
