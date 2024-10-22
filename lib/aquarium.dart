import 'package:flutter/material.dart';
import 'dart:math';
import 'fish.dart';
import 'database_helper.dart';

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> with SingleTickerProviderStateMixin {
  List<Fish> fishList = [];
  Color selectedColor = Colors.red;
  double selectedSpeed = 1.0;
  bool collisionEffectEnabled = true;

  late AnimationController _controller;

  final Map<Color, String> colorOptions = {
    Colors.red: "Red",
    Colors.green: "Green",
    Colors.yellow: "Yellow",
    Colors.orange: "Orange",
    Colors.purple: "Purple"
  };

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _controller.addListener(_updateFishPositions);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSavedSettings() async {
    final settings = await DatabaseHelper.loadSettings();
    setState(() {
      selectedSpeed = settings['speed'];
      selectedColor = Color(settings['color']);
      if (!_colorInDropdown(selectedColor)) {
        selectedColor = Colors.red;
      }
      int fishCount = settings['fishCount'];
      for (int i = 0; i < fishCount; i++) {
        fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
      }
    });
  }

  Future<void> _saveSettings() async {
    await DatabaseHelper.saveSettings(fishList.length, selectedSpeed, selectedColor.value);
  }

  void _addFish() {
    if (fishList.length < 10) {
      setState(() {
        fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
        _saveSettings();
      });
    }
  }

  void _updateFishPositions() {
    setState(() {
      for (var fish in fishList) {
        fish.moveFish();
      }
      if (collisionEffectEnabled) {
        _checkAllCollisions();
      }
    });
  }

  void _checkForCollision(Fish fish1, Fish fish2) {
    if ((fish1.position.dx - fish2.position.dx).abs() < 20 &&
        (fish1.position.dy - fish2.position.dy).abs() < 20) {
      fish1.changeDirection();
      fish2.changeDirection();
      setState(() {
        fish1.color = Random().nextBool() ? Colors.red : Colors.green;
      });
    }
  }

  void _checkAllCollisions() {
    for (int i = 0; i < fishList.length; i++) {
      for (int j = i + 1; j < fishList.length; j++) {
        _checkForCollision(fishList[i], fishList[j]);
      }
    }
  }

  bool _colorInDropdown(Color color) {
    return colorOptions.keys.contains(color);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Virtual Aquarium')),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: Container(
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: fishList.map((fish) => fish.buildFish()).toList(),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _addFish, child: Text('Add Fish')),
                  ElevatedButton(onPressed: _saveSettings, child: Text('Save Settings')),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Slider(
                  value: selectedSpeed,
                  onChanged: (newSpeed) {
                    setState(() {
                      selectedSpeed = newSpeed;
                    });
                    _saveSettings();
                  },
                  min: 0.5,
                  max: 3.0,
                  divisions: 5,
                  label: '$selectedSpeed',
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: DropdownButton<Color>(
                  value: selectedColor,
                  items: colorOptions.keys.map((Color color) {
                    return DropdownMenuItem<Color>(
                      value: color,
                      child: Text(colorOptions[color] ?? 'Unknown', style: TextStyle(color: color)),
                    );
                  }).toList(),
                  onChanged: (color) {
                    setState(() {
                      selectedColor = color ?? Colors.red;
                    });
                    _saveSettings();
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              SwitchListTile(
                title: Text('Enable Collision Effect'),
                value: collisionEffectEnabled,
                onChanged: (bool value) {
                  setState(() {
                    collisionEffectEnabled = value;
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
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.white.withOpacity(0.8),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Basith Abdul\nPanther ID: 002838231',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black),
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
