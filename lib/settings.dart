import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class Settings {
  static double recordInputCellHeight = 100;
  static double recordOutputCellHeight = 200;
  static double interactiveCellHeight = 300;
  static double terminalViewPadding = 8;

  static Color inputBorderColor = Colors.white;
  static Color outputBorderColor = Colors.blue;
  static Color interactiveBorderColor = Colors.green;
}

class TerminalViewEncloser extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final Color marginColor;

  const TerminalViewEncloser(
      {super.key,
      required this.child,
      required this.borderWidth,
      required this.marginColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(borderWidth),
      color: marginColor,
      child: child,
    );
  }
}

class InputEncloser extends StatelessWidget {
  final Widget child;

  const InputEncloser({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TerminalViewEncloser(
        borderWidth: Settings.terminalViewPadding,
        marginColor: Settings.inputBorderColor,
        child: child);
  }
}

class OutputEncloser extends StatelessWidget {
  final Widget child;

  const OutputEncloser({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TerminalViewEncloser(
        borderWidth: Settings.terminalViewPadding,
        marginColor: Settings.outputBorderColor,
        child: child);
  }
}

class InteractiveTerminalEncloser extends StatelessWidget {
  final Widget child;

  const InteractiveTerminalEncloser({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TerminalViewEncloser(
        borderWidth: Settings.terminalViewPadding,
        marginColor: Settings.interactiveBorderColor,
        child: child);
  }
}
