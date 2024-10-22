import 'package:flutter/material.dart';
import 'dart:math';
import 'fish.dart';
import 'database_helper.dart';

class AquariumPage extends StatefulWidget {
  @override
  _AquariumPageState createState() => _AquariumPageState();
}

class _AquariumPageState extends State<AquariumPage> with SingleTickerProviderStateMixin {
  List<Fish> aquariumFish = [];
  Color currentColor = Colors.blueAccent;
  double fishSpeed = 1.0;
  bool isCollisionEnabled = true;

  late AnimationController animationController;

  final Map<Color, String> colorChoices = {
    Colors.blueAccent: "Blue",
    Colors.pink: "Pink",
    Colors.teal: "Teal",
    Colors.yellow: "Yellow",
    Colors.purpleAccent: "Purple"
  };

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    animationController.addListener(_moveFish);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserSettings() async {
    final settings = await DBHelper.loadConfig();
    setState(() {
      fishSpeed = settings['speed'];
      currentColor = Color(settings['color']);
      if (!_isColorInChoices(currentColor)) {
        currentColor = Colors.blueAccent;
      }
      int fishCount = settings['fishCount'];
      for (int i = 0; i < fishCount; i++) {
        aquariumFish.add(Fish(color: currentColor, speed: fishSpeed));
      }
    });
  }

  Future<void> _saveUserSettings() async {
    await DBHelper.saveConfig(aquariumFish.length, fishSpeed, currentColor.value);
  }

  void _addNewFish() {
    if (aquariumFish.length < 12) {
      setState(() {
        aquariumFish.add(Fish(color: currentColor, speed: fishSpeed));
        _saveUserSettings();
      });
    }
  }

  void _moveFish() {
    setState(() {
      for (var fish in aquariumFish) {
        fish.updatePosition();
      }
      if (isCollisionEnabled) {
        _detectCollisions();
      }
    });
  }

  void _detectCollisions() {
    for (int i = 0; i < aquariumFish.length; i++) {
      for (int j = i + 1; j < aquariumFish.length; j++) {
        _handleCollision(aquariumFish[i], aquariumFish[j]);
      }
    }
  }

  void _handleCollision(Fish fishA, Fish fishB) {
    if ((fishA.position.dx - fishB.position.dx).abs() < 20 &&
        (fishA.position.dy - fishB.position.dy).abs() < 20) {
      fishA.changeDirection();
      fishB.changeDirection();
      setState(() {
        fishA.color = Random().nextBool() ? Colors.blueAccent : Colors.pink;
      });
    }
  }

  bool _isColorInChoices(Color color) {
    return colorChoices.keys.contains(color);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Virtual Aquarium App - Basith Abdul'),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: screenHeight * 0.03),
              Center(
                child: Container(
                  width: screenWidth * 0.85,
                  height: screenHeight * 0.45,
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: aquariumFish.map((fish) => fish.render()).toList(),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _addNewFish,
                    child: Text('Add Fish'),
                  ),
                  ElevatedButton(
                    onPressed: _saveUserSettings,
                    child: Text('Save Settings'),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Slider(
                  value: fishSpeed,
                  onChanged: (newSpeed) {
                    setState(() {
                      fishSpeed = newSpeed;
                    });
                    _saveUserSettings();
                  },
                  min: 0.5,
                  max: 3.0,
                  divisions: 5,
                  label: '$fishSpeed',
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: DropdownButton<Color>(
                  value: currentColor,
                  items: colorChoices.keys.map((Color color) {
                    return DropdownMenuItem<Color>(
                      value: color,
                      child: Text(
                        colorChoices[color] ?? 'Unknown',
                        style: TextStyle(color: color),
                      ),
                    );
                  }).toList(),
                  onChanged: (color) {
                    setState(() {
                      currentColor = color ?? Colors.blueAccent;
                    });
                    _saveUserSettings();
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              SwitchListTile(
                title: Text('Enable Collision Detection'),
                value: isCollisionEnabled,
                onChanged: (bool value) {
                  setState(() {
                    isCollisionEnabled = value;
                  });
                },
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                color: Colors.white.withOpacity(0.85),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Panther ID: 002838231',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
