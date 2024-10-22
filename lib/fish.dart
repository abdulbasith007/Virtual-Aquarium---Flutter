import 'package:flutter/material.dart';
import 'dart:math';

class Fish {
  Color color;
  final double speed;
  Offset position;
  Random rng = Random();

  Fish({required this.color, required this.speed})
      : position = Offset(150, 150);

  void updatePosition() {
    double dx = rng.nextDouble() * 2 - 1;
    double dy = rng.nextDouble() * 2 - 1;
    position = Offset(position.dx + dx * speed, position.dy + dy * speed);
  }

  void changeDirection() {
    // Direction change logic can be added here
  }

  Widget render() {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
