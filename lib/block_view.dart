import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:terminal_test/utils.dart';
// import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';
import 'package:flutter_pty/flutter_pty.dart';

class TerminalTextBlock extends StatelessWidget {
  final String text;

  const TerminalTextBlock({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    var terminal = Terminal(maxLines: 100);
    var terminalView = TerminalView(terminal);
    terminal.write(text);
    print('text: $text');

    return ConstrainedBox(
        constraints: BoxConstraints.loose(Size(800, 600)),
        child: Container(padding: EdgeInsets.all(8), child: terminalView));
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
        TerminalTextBlock(text: record.prompt + record.input),
        // Text(record.prompt + record.input),
        TerminalTextBlock(text: record.output)
        // Text(record.output)
      ],
    );
  }
}
