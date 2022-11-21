import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:terminal_test/block_view.dart';
import 'package:terminal_test/utils.dart' as utils;
import 'package:terminal_test/constants.dart';

class BlockedTerminal extends StatefulWidget {
  const BlockedTerminal({super.key});

  @override
  State<BlockedTerminal> createState() => _BlockedTerminalState();
}

class _BlockedTerminalState extends State<BlockedTerminal> {
  late final Pty pty;

  utils.TerminalState currentState = utils.TerminalState.execution;

  List<String> outputBuffer = [];
  String lastCommand = '';
  String currentCommand = '';
  String currentPrompt = '';
  Terminal terminal = Terminal();

  bool firstPromptDisplayed = false;

  RegExp promptMatcher = RegExp(promptPattern);
  // RegExp promptMatcher = RegExp(bufferPromptPattern);
  RegExp bufferPromptMatcher = RegExp(bufferPromptPattern);

  List<utils.ExecutionRecord> executionRecords = [];

  _BlockedTerminalState() {
    pty = Pty.start("bash");

    pty.output.cast<List<int>>().transform(const Utf8Decoder()).listen((data) {
      // write to terminal
      terminal.write(data);

      // get buffer text
      var bufferList = terminal.lines.toList();
      bufferList.removeWhere((element) => element.toString() == '');
      var bufferText = bufferList.join('\n');

      // update current command
      var matches = bufferPromptMatcher.allMatches(bufferText).toList();
      if (matches.isNotEmpty) {
        currentCommand = bufferText.substring(matches[matches.length - 1].end);
      }
      // else {
      // currentCommand = '';
      // }

      switch (currentState) {
        case utils.TerminalState.input:
          // if (currentCommand.isNotEmpty) {}
          break;
        case utils.TerminalState.execution:
          var match = promptMatcher.firstMatch(data);
          if (match == null) {
            // execution incomplete
            outputBuffer.add(data);
          } else {
            // execution complete
            outputBuffer.add(data.substring(0, match.start));
            var lastPrompt = currentPrompt;
            currentPrompt = data.substring(match.start);

            currentState = utils.TerminalState.input;

            // add new I/O block view
            if (firstPromptDisplayed) {
              executionRecords.add(utils.ExecutionRecord(
                  prompt: lastPrompt,
                  input: lastCommand,
                  output: outputBuffer.join('')));
              // clear the terminal
              terminal.buffer.clear();
              terminal.write(currentPrompt);
            } else {
              firstPromptDisplayed = true;
            }

            // clear terminal

            print('total output: ${outputBuffer.join('')}');
            print('new prompt: $currentPrompt');

            outputBuffer.clear();
          }
          break;
      }

      setState(() {});
    });

    terminal.onOutput = (data) {
      if (Detectors.detectCommandSubmitter(data) &&
          (currentCommand.isEmpty ||
              !Detectors.detectContinuer(
                  currentCommand[currentCommand.length - 1]))) {
        // submit command
        print('submit command: $currentCommand');
        lastCommand = currentCommand;
        currentCommand = '';
      }

      currentState = utils.TerminalState.execution;
      outputBuffer.clear();

      pty.write(const Utf8Encoder().convert(data));
    };

    pty.exitCode.then((_) {
      // inputBuffer.clear();
      currentCommand = '';
      SystemNavigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    // print('build: record length: ${executionRecords.length}');
    return ListView(
        children: executionRecords
                .map((e) => TerminalExecutionBlockView(record: e) as Widget)
                // .map((e) => Text(e.output) as Widget)
                // .map((e) => Text('cute') as Widget)
                .toList() +
            [
              ConstrainedBox(
                  constraints: BoxConstraints.loose(Size(800, 600)),
                  child: TerminalView(terminal))
            ]);
  }
}
