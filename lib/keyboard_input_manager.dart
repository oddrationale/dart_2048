library dart_2048.keyboard_input_manager;

import 'dart:html';
import 'dart:math' show max;

class KeyboardInputManager {
  Function moveEvent;
  Function restartEvent;
  Function keepPlayingEvent;

  KeyboardInputManager() {
    listen();
  }
  // TODO: Clean this up. Use Futures?
  void onMove(void callback(int direction)) {
    moveEvent = callback;
  }

  void onRestart(void callback()) {
    restartEvent = callback;
  }

  void onKeepPlaying(void callback()) {
    keepPlayingEvent = callback;
  }

  void emitMove(int direction) {
    moveEvent(direction);
  }

  void emitRestart() {
    restartEvent();
  }

  void emitKeepPlaying() {
    keepPlayingEvent();
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
      bool modifiers =
          event.altKey || event.ctrlKey || event.metaKey || event.shiftKey;
      int mapped = map[event.which];

      if (!modifiers && mapped != null) {
        event.preventDefault();
        emitMove(mapped);
      }

      // R key restarts the game
      if (!modifiers && event.which == KeyCode.R) {
        restart(event);
      }
    });

    // Respond to button presses
    bindButtonPress(".retry-button", restart);
    bindButtonPress(".restart-button", restart);
    bindButtonPress(".keep-playing-button", keepPlaying);

    // Respond to swipe events
    int touchStartClientX, touchStartClientY;
    DivElement gameContainer = querySelector(".game-container");

    gameContainer.onTouchStart.listen((TouchEvent event) {
      if (event.touches.length > 1) {
        return; // Ignore if touching with more than 1 finger
      }

      touchStartClientX = event.touches[0].client.x;
      touchStartClientY = event.touches[0].client.y;

      event.preventDefault();
    });

    gameContainer.onTouchMove.listen((TouchEvent event) {
      event.preventDefault();
    });

    gameContainer.onTouchEnd.listen((TouchEvent event) {
      if (event.touches.length > 1) {
        return; // Ignore if still touching with one or more fingers
      }

      int touchEndClientX, touchEndClientY;

      touchEndClientX = event.changedTouches[0].client.x;
      touchEndClientY = event.changedTouches[0].client.y;

      int dx = touchEndClientX - touchStartClientX;
      int absDx = dx.abs();

      int dy = touchEndClientY - touchStartClientY;
      int absDy = dy.abs();

      if (max(absDx, absDy) > 10) {
        // (right : left) : (down : up)
        emitMove(absDx > absDy ? (dx > 0 ? 1 : 3) : (dy > 0 ? 2 : 0));
      }
    });
  }

  void restart(Event event) {
    event.preventDefault();
    emitRestart();
  }

  void keepPlaying(Event event) {
    event.preventDefault();
    emitKeepPlaying();
  }

  void bindButtonPress(String selector, Function fn) {
    AnchorElement button = querySelector(selector);
    button.onClick.listen(fn);
    button.onTouchEnd.listen(fn);
  }
}
