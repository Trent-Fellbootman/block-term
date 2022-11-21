import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Settings {
  // generic settings
  static double recordInputCellHeight = 100;
  static double recordOutputCellHeight = 200;
  static double interactiveCellHeight = 300;

  // border settings
  static double terminalViewBorderSize = 8;
  static Color inputBorderColor = Colors.white;
  static Color outputBorderColor = Colors.blue;
  static Color interactiveBorderColor = Colors.green;

  // progress bar settings
  static Widget inProgressAnimation = Container(
      margin: const EdgeInsets.all(4),
      child:
          LoadingAnimationWidget.discreteCircle(color: Colors.white, size: 14));
  static Widget completedIcon = Container(
      margin: const EdgeInsets.all(4),
      child: const Icon(
        Icons.check,
        color: Colors.green,
      ));
  static TextStyle progressBarTextStyle = const TextStyle(fontSize: 14);
  static int progressBarTimeDigits = 2;
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
        borderWidth: Settings.terminalViewBorderSize,
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
        borderWidth: Settings.terminalViewBorderSize,
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
        borderWidth: Settings.terminalViewBorderSize,
        marginColor: Settings.interactiveBorderColor,
        child: child);
  }
}
