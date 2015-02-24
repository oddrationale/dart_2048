// Copyright (c) 2015, Dariel Dato-on. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library dart_2048;

import 'dart:html';
import 'package:dart_2048/game_manager.dart';

void main() {
  window.requestAnimationFrame((_) {
    GameManager game = new GameManager(4);
  });
}
