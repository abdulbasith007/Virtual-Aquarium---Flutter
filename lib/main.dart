import 'package:flutter/material.dart';
import 'aquarium.dart';

void main() {
  runApp(AquariumApp());
}

class AquariumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Aquarium App - Basith Abdul',
      theme: ThemeData.light(),
      home: AquariumPage(),
    );
  }
}
