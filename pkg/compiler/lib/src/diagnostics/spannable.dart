// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library;

/// Tagging interface for classes from which source spans can be generated.
abstract class Spannable {}

class _SpannableSentinel implements Spannable {
  final String name;

  const _SpannableSentinel(this.name);

  @override
  String toString() => name;
}

/// Sentinel spannable used to mark that diagnostics should point to the
/// current element. Note that the diagnostic reporting will fail if the current
/// element is `null`.
const Spannable currentElementSpannable = _SpannableSentinel("Current element");

/// Sentinel spannable used to mark that there might be no location for the
/// diagnostic. Use this only when it is not an error not to have a current
/// element.
const Spannable noLocationSpannable = _SpannableSentinel("No location");

class SpannableAssertionFailure {
  final Spannable node;
  final String? message;
  SpannableAssertionFailure(this.node, this.message);

  @override
  String toString() =>
      'Assertion failure'
      '${message != null ? ': $message' : ''}';
}
