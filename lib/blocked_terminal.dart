import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:terminal_test/block_view.dart';
import 'package:terminal_test/utils.dart' as utils;
import 'package:terminal_test/constants.dart';
import 'package:terminal_test/settings.dart' as settings;
import 'ui_elements.dart';

class TerminalReference {
  Terminal terminal = Terminal();
}

class BlockedTerminal extends StatefulWidget {
  const BlockedTerminal({super.key});

  @override
  State<BlockedTerminal> createState() => _BlockedTerminalState();
}

class _BlockedTerminalState extends State<BlockedTerminal> {
  late final Pty pty;

  utils.TerminalState currentState = utils.TerminalState.execution;

  late Function(String) onTerminalOutputCallback;

  List<String> outputBuffer = [];
  String lastCommand = '';
  String currentCommand = '';
  String currentPrompt = '';
  TerminalReference terminalReference = TerminalReference();
  // Terminal terminal = Terminal();

  DateTime executionStart = DateTime.now();
  late Duration lastElapsedTime;

  bool firstPromptDisplayed = false;

  RegExp promptMatcher = RegExp(promptPattern);
  // RegExp promptMatcher = RegExp(bufferPromptPattern);
  RegExp bufferPromptMatcher = RegExp(bufferPromptPattern);

  List<utils.ExecutionRecord> executionRecords = [];

  Terminal createTerminal() {
    var terminal = Terminal();
    terminal.setAutoWrapMode(true);
    return terminal;
  }

  TerminalView createTerminalView(Terminal terminal) {
    var view = TerminalView(
      terminal,
      autofocus: true,
    );
    return view;
  }

  final ScrollController _controller = ScrollController();

  void _scrollToBottom() {
    _controller.animateTo(
      _controller.position.maxScrollExtent * 2,
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
    // _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  _BlockedTerminalState() {
    terminalReference.terminal = createTerminal();
    pty = Pty.start("bash");

    pty.output.cast<List<int>>().transform(const Utf8Decoder()).listen((data) {
      // write to terminal
      terminalReference.terminal.write(data);

      // get buffer text
      var bufferList = terminalReference.terminal.lines.toList();
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

            lastElapsedTime = DateTime.now().difference(executionStart);

            currentState = utils.TerminalState.input;

            if (firstPromptDisplayed) {
              // add new I/O block view
              executionRecords.add(
                utils.ExecutionRecord(
                    prompt: lastPrompt,
                    input: lastCommand,
                    output: outputBuffer.join(''),
                    elapsedTime: lastElapsedTime),
              );
              // clear the terminal
              terminalReference.terminal = createTerminal();
              terminalReference.terminal.onOutput = onTerminalOutputCallback;
              // terminal.buffer.lines.clear();
              terminalReference.terminal.write(currentPrompt);
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
      _scrollToBottom();
    });

    onTerminalOutputCallback = (data) {
      if (Detectors.detectCommandSubmitter(data) &&
          (currentCommand.isEmpty ||
              !Detectors.detectContinuer(
                  currentCommand[currentCommand.length - 1]))) {
        // submit command
        print('submit command: $currentCommand');
        currentState = utils.TerminalState.execution;
        executionStart = DateTime.now();
        outputBuffer.clear();
        lastCommand = currentCommand;
        currentCommand = '';
      }

      pty.write(const Utf8Encoder().convert(data));
    };

    terminalReference.terminal.onOutput = onTerminalOutputCallback;

    pty.exitCode.then((_) {
      // inputBuffer.clear();
      currentCommand = '';
      SystemNavigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    // print('build: record length: ${executionRecords.length}');

    var interactiveTerminalView = ConstrainedBox(
        constraints: BoxConstraints.loose(
            Size(double.infinity, settings.Settings.interactiveCellHeight)),
        child: createTerminalView(terminalReference.terminal));

    return ListView(
        controller: _controller,
        children: executionRecords
                .map((e) => TerminalExecutionBlockView(record: e) as Widget)
                // .map((e) => Text(e.output) as Widget)
                // .map((e) => Text('cute') as Widget)
                .toList() +
            [
              settings.InteractiveTerminalEncloser(
                  child: Column(
                      children: currentState == utils.TerminalState.execution
                          ? [
                              interactiveTerminalView,
                              ProgressIndicatorBar(
                                  isCompleted: false,
                                  time:
                                      DateTime.now().difference(executionStart))
                            ]
                          : [interactiveTerminalView]))
            ]);
  }
}
