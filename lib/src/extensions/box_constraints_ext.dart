import 'package:flutter/material.dart';

// ignore: prefer-match-file-name
extension BoxConstraintsExtensions on BoxConstraints {
  double maxForDirection(Axis direction) => switch (direction) {
        Axis.horizontal => maxWidth,
        Axis.vertical => maxHeight,
      };
}
