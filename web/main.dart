// Copyright (c) 2015, Dariel Dato-on. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:dart_2048/keyboard_input_manager.dart';

void main() {
  var k = new KeyboardInputManager();
  k.onMove((x) => print(x));
  k.onRestart(() => print("restart"));
  k.onKeepPlaying(() => print("keep playing"));
}
