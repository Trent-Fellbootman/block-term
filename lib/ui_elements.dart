import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'settings.dart' as settings;

class ProgressIndicatorBar extends StatelessWidget {
  final bool isCompleted;
  final Duration time;

  const ProgressIndicatorBar(
      {super.key, required this.isCompleted, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
            child: isCompleted
                ? settings.Settings.completedIcon
                : settings.Settings.inProgressAnimation),
        Center(
            child: Text(
          time.toString(),
          textAlign: TextAlign.center,
          style: settings.Settings.progressBarTextStyle,
        ))
      ],
    ));
  }
}
