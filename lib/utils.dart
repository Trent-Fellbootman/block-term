import 'dart:ffi';

import 'package:flutter/foundation.dart';

enum TerminalState { input, execution }

class ExecutionRecord {
  final String prompt;
  final String input;
  final String output;
  final Duration elapsedTime;

  ExecutionRecord(
      {required this.prompt,
      required this.input,
      required this.output,
      required this.elapsedTime});
}
