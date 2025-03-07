// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// VMOptions=
// VMOptions=--dwarf_stack_traces --no-retain_function_objects --no-retain_code_objects

import "package:expect/async_helper.dart";
import "package:expect/expect.dart";
import "shared_and_unshared_classes_lib1.dart" deferred as lib1;
import "shared_and_unshared_classes_lib2.dart" deferred as lib2;
import "dart:async";

void main() {
  asyncTest(() {
    return Future.wait([
      lib1.loadLibrary().then((_) {
        lib1.foo();
      }),
      lib2.loadLibrary().then((_) {
        lib2.foo();
      }),
    ]);
  });
}
