import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:terminal_test/utils.dart';
// import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:terminal_test/settings.dart' as settings;

class TerminalTextBlock extends StatelessWidget {
  final String text;
  final double height;

  const TerminalTextBlock(
      {super.key, required this.text, required this.height});

  @override
  Widget build(BuildContext context) {
    var terminal = Terminal();
    terminal.write(text);
    var terminalView = TerminalView(terminal, readOnly: true);
    print('text: $text');

    return SizedBox(height: height, child: terminalView);
  }
}

class TerminalInputBlock extends StatefulWidget {
  final Pty pty;

  const TerminalInputBlock({super.key, required this.pty});

  @override
  State<StatefulWidget> createState() => _TerminalInputBlockState(pty: pty);
}

class _TerminalInputBlockState extends State<TerminalInputBlock> {
  final Pty pty;

  bool activated = true;

  _TerminalInputBlockState({required this.pty});

  @override
  Widget build(BuildContext context) {
    var terminal = Terminal(
      onOutput: (data) {
        pty.write(const Utf8Encoder().convert(data));
      },
    );

    return TerminalView(terminal);
  }

  void activateInput() {
    activated = true;
  }

  void deactivateInput() {
    activated = false;
  }
}

class TerminalExecutionBlockView extends StatelessWidget {
  final ExecutionRecord record;

  const TerminalExecutionBlockView({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        settings.InputEncloser(
            child: TerminalTextBlock(
                text: record.prompt + record.input,
                height: settings.Settings.recordInputCellHeight)),
        // Text(record.prompt + record.input),
        settings.OutputEncloser(
            child: TerminalTextBlock(
          text: record.output,
          height: settings.Settings.recordOutputCellHeight,
        ))
        // Text(record.output)
      ],
    );
  }
}
