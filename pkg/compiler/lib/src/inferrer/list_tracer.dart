// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library;

import '../common/names.dart';
import '../elements/entities.dart';
import '../native/behavior.dart';
import '../util/util.dart' show Setlet;
import 'node_tracer.dart';
import 'type_graph_nodes.dart';

/// A set of selector names that [List] implements, that we know do not
/// change the element type of the list, or let the list escape to code
/// that might change the element type.
Set<String> elementTypePreservingSelectorNames = <String>{
  // From Object.
  '==',
  'hashCode',
  'toString',
  'noSuchMethod',
  'runtimeType',

  // From Iterable.
  'iterator',
  'map',
  'where',
  'expand',
  'contains',
  'forEach',
  'reduce',
  'fold',
  'every',
  'join',
  'any',
  'toList',
  'toSet',
  'length',
  'isEmpty',
  'isNotEmpty',
  'take',
  'takeWhile',
  'skip',
  'skipWhile',
  'single',
  'firstWhere',
  'lastWhere',
  'singleWhere',
  'elementAt',

  // From List.
  '[]',
  'reversed',
  'sort',
  'indexOf',
  'lastIndexOf',
  'clear',
  'remove',
  'removeAt',
  'removeLast',
  'removeWhere',
  'retainWhere',
  'sublist',
  'getRange',
  'removeRange',
  'asMap',

  // From JSArray.
  'checkMutable',
  'checkGrowable',
};

Set<String> lengthPreservingSelectorNames = <String>{
  // From Object.
  '==',
  'hashCode',
  'toString',
  'noSuchMethod',
  'runtimeType',

  // From Iterable.
  'iterator',
  'map',
  'where',
  'expand',
  'contains',
  'forEach',
  'reduce',
  'fold',
  'every',
  'join',
  'any',
  'toList',
  'toSet',
  'isEmpty',
  'isNotEmpty',
  'take',
  'takeWhile',
  'skip',
  'skipWhile',
  'first',
  'last',
  'single',
  'firstWhere',
  'lastWhere',
  'singleWhere',
  'elementAt',

  // From List.
  '[]',
  '[]=',
  'reversed',
  'sort',
  'indexOf',
  'lastIndexOf',
  'sublist',
  'getRange',
  'asMap',

  // From JSArray.
  'checkMutable',
  'checkGrowable',
};

class ListTracerVisitor extends TracerVisitor {
  // The [Set] of found assignments to the list.
  Set<TypeInformation> inputs = Setlet<TypeInformation>();
  bool callsGrowableMethod = false;

  ListTracerVisitor(super.tracedType, super.inferrer);

  /// Returns [true] if the analysis completed successfully, [false] if it
  /// bailed out. In the former case, [inputs] holds a list of
  /// [TypeInformation] nodes that flow into the element type of this list.
  bool run() {
    analyze();
    final list = tracedType as ListTypeInformation;
    if (continueAnalyzing) {
      if (!callsGrowableMethod && list.inferredLength == null) {
        list.inferredLength = list.originalLength;
      }
      list.addFlowsIntoTargets(flowsInto);
      return true;
    } else {
      callsGrowableMethod = true;
      inputs.clear();
      return false;
    }
  }

  @override
  void visitClosureCallSiteTypeInformation(
    ClosureCallSiteTypeInformation info,
  ) {
    bailout('Passed to a closure');
  }

  @override
  void visitStaticCallSiteTypeInformation(StaticCallSiteTypeInformation info) {
    super.visitStaticCallSiteTypeInformation(info);
    final commonElements = inferrer.closedWorld.commonElements;
    MemberEntity called = info.calledElement;
    if (commonElements.isForeign(called) && called.name == Identifiers.js) {
      NativeBehavior nativeBehavior = inferrer.closedWorld.elementMap
          .getNativeBehaviorForJsCall(info.invocationNode);
      // Assume side-effects means that the list has escaped to some unknown
      // location.
      if (nativeBehavior.sideEffects.hasSideEffects()) {
        bailout('Used in JS ${info.debugName}');
      }
    }
  }

  @override
  void visitDynamicCallSiteTypeInformation(
    DynamicCallSiteTypeInformation info,
  ) {
    super.visitDynamicCallSiteTypeInformation(info);
    final selector = info.selector!;
    String selectorName = selector.name;
    final arguments = info.arguments;
    if (currentUser == info.receiver) {
      if (!elementTypePreservingSelectorNames.contains(selectorName)) {
        if (selectorName == 'add' && selector.isCall) {
          if (arguments!.positional.length == 1) {
            inputs.add(arguments.positional[0]);
          }
        } else if (selectorName == 'insert' && selector.isCall) {
          if (arguments!.positional.length == 2) {
            inputs.add(arguments.positional[1]);
          }
        } else if (selectorName == 'first' || selectorName == 'last') {
          if (selector.isSetter) {
            if (arguments!.positional.length == 1) {
              inputs.add(arguments.positional[0]);
            }
          }
          // 'first' and 'last' getter are safe.
        } else if (selector.isIndexSet) {
          inputs.add(arguments!.positional[1]);
        } else if (selector.isIndex) {
          // Index lookup is safe.
        } else {
          bailout('Used in a not-ok selector');
          return;
        }
      }
      if (!lengthPreservingSelectorNames.contains(selectorName)) {
        if (selectorName == 'length') {
          if (selector.isSetter) {
            callsGrowableMethod = true;
            inputs.add(inferrer.types.nullType);
          }
        } else {
          callsGrowableMethod = true;
        }
      }
    } else if (selector.isCall &&
        (info.hasClosureCallTargets || dynamicCallTargetsNonFunction(info))) {
      bailout('Passed to a closure');
      return;
    }
  }
}
