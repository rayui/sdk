// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:compiler/src/compiler.dart';
import 'package:compiler/src/elements/entities.dart';
import 'package:compiler/src/js_emitter/program_builder/program_builder.dart';
import 'package:compiler/src/js_model/js_world.dart' show JClosedWorld;
import 'package:expect/async_helper.dart';
import 'package:expect/expect.dart';
import '../helpers/program_lookup.dart';
import 'package:compiler/src/util/memory_compiler.dart';

main() {
  runTest() async {
    CompilationResult result = await runCompiler(
      entryPoint: Platform.script.resolve('data/subtype_named_args.dart'),
    );
    Expect.isTrue(result.isSuccess);
    Compiler compiler = result.compiler!;
    JClosedWorld closedWorld = compiler.backendClosedWorldForTesting!;
    ProgramLookup programLookup = ProgramLookup(compiler.backendStrategy);

    List<ClassEntity> found = <ClassEntity>[];
    for (ClassEntity element in Collector.getBackendTypeHelpers(
      closedWorld.commonElements,
    )) {
      if (programLookup.getClass(element) != null) {
        found.add(element);
      }
    }
    Expect.isTrue(found.isEmpty, "Classes ${found} should not be emitted");
  }

  asyncTest(() async {
    print('--test from kernel------------------------------------------------');
    await runTest();
  });
}
