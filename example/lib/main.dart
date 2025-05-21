import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:temi/temi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _temi = Temi();
  double _xValue = 0.0;
  double _yValue = 0.0;
  bool _smartMode = false;

  String _robotStatus = 'Unknown';
  String _detectionState = 'Unknown';
  String _userInteraction = 'None';
  int _batteryLevel = 0;
  bool _isRobotReady = false;
  List<String> _locations = [];
  String _currentSpeechText = '';

  Future<void> _moveRobot() async {
    final success = await _temi.skidJoy(_xValue, _yValue, smart: _smartMode);
    if (success) {
      print('Robot moving with x: $_xValue, y: $_yValue, smart: $_smartMode');
    } else {
      print('Failed to move robot');
    }
  }

  Future<void> _updateRobotInfo() async {
    try {
      final battery = await _temi.getBatteryLevel();
      final locations = await _temi.getLocations();
      final robotInfo = await _temi.getRobotInfo();

      setState(() {
        _batteryLevel = battery;
        _locations = locations;
        _robotStatus = robotInfo.isNotEmpty ? 'Connected' : 'Disconnected';
      });
    } catch (e) {
      print('Error updating robot info: $e');
    }
  }

  Future<void> _speakText() async {
    if (_currentSpeechText.isNotEmpty) {
      await _temi.speak(_currentSpeechText);
    }
  }

  Future<void> _performGreeting() async {
    //await _temi.greetUser();
  }

  Future<void> _performGoodbye() async {
    //await _temi.sayGoodbye();
  }

  Future<void> _emergencyStop() async {
    // await _temi.emergencyStop();
  }

  @override
  void initState() {
    super.initState();

    _temi.initialize(
      enableDetection: true,
      enableUserTracking: false,
      privacyMode: false,
    );

    _temi.setupAllListeners(
      onRobotReady: (isReady) {
        setState(() {
          _isRobotReady = isReady;
        });
        print('Robot ready: $isReady');
        if (isReady) {
          _updateRobotInfo();
        }
      },
      onUserInteraction: (isInteracting) {
        if (isInteracting) {
          _temi.speak("User interact wit me ");
        }
        setState(() {
          _userInteraction = isInteracting ? 'Interacting' : 'Not Interacting';
        });
        print('User interacting: $isInteracting');
      },
      onDetectionStateChanged: (state) {
        if (state == 2) {
          _temi.speak("User focus mode");
        } else if (state == 1) {
          _temi.speak("User out of focus");
        }
        setState(() {
          _detectionState = 'State: $state';
        });
        print('Detection state: $state');
      },
      onGoToLocationStatusChanged: (
        location,
        status,
        descriptionId,
        description,
      ) {
        print(
          'Location: $location, Status: $status, Description: $description',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation: $location - $status')),
        );
      },
      onTtsStatusChanged: (id, text, status) {
        print('TTS: $text - $status');
      },
    );

    // Update robot info periodically
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isRobotReady) {
        _updateRobotInfo();
      }
    });
  }

  @override
  void dispose() {
    _temi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Temi Flutter Plugin'),
          backgroundColor: Colors.blue.shade700,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Robot Status Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Robot Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _isRobotReady ? Icons.check_circle : Icons.error,
                            color: _isRobotReady ? Colors.green : Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('Ready: ${_isRobotReady ? "Yes" : "No"}'),
                        ],
                      ),
                      Text('Status: $_robotStatus'),
                      Text('Detection: $_detectionState'),
                      Text('User: $_userInteraction'),
                      Row(
                        children: [
                          Icon(
                            Icons.battery_full,
                            color:
                                _batteryLevel > 20 ? Colors.green : Colors.red,
                          ),
                          Text(' Battery: $_batteryLevel%'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Manual Movement Controls
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manual Movement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('X (Turn): ${_xValue.toStringAsFixed(2)}'),
                      Slider(
                        value: _xValue,
                        min: -1.0,
                        max: 1.0,
                        divisions: 20,
                        onChanged: (value) {
                          setState(() {
                            _xValue = value;
                          });
                        },
                        onChangeEnd: (_) => _moveRobot(),
                      ),
                      Text(
                        'Y (Forward/Backward): ${_yValue.toStringAsFixed(2)}',
                      ),
                      Slider(
                        value: _yValue,
                        min: -1.0,
                        max: 1.0,
                        divisions: 20,
                        onChanged: (value) {
                          setState(() {
                            _yValue = value;
                          });
                        },
                        onChangeEnd: (_) => _moveRobot(),
                      ),
                      SwitchListTile(
                        title: Text('Smart Mode'),
                        value: _smartMode,
                        onChanged: (value) {
                          setState(() {
                            _smartMode = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Quick Movement Buttons
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Controls',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _temi.moveForward(),
                            icon: Icon(Icons.keyboard_arrow_up),
                            label: Text('Forward'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _temi.moveBackward(),
                            icon: Icon(Icons.keyboard_arrow_down),
                            label: Text('Backward'),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _temi.turnLeft(),
                            icon: Icon(Icons.keyboard_arrow_left),
                            label: Text('Turn Left'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _temi.turnRight(),
                            icon: Icon(Icons.keyboard_arrow_right),
                            label: Text('Turn Right'),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _emergencyStop,
                          icon: Icon(Icons.stop),
                          label: Text('EMERGENCY STOP'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Advanced Movement Patterns
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Movement Patterns',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => {},
                            icon: Icon(Icons.crop_square),
                            label: Text('Square'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => {},
                            icon: Icon(Icons.circle_outlined),
                            label: Text('Circle'),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => {},
                            icon: Icon(Icons.rotate_right),
                            label: Text('Turn 90°'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => {},
                            icon: Icon(Icons.rotate_left),
                            label: Text('Turn -90°'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Speech Controls
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Speech Controls',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Text to speak',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.volume_up),
                            onPressed: _speakText,
                          ),
                        ),
                        onChanged: (value) {
                          _currentSpeechText = value;
                        },
                        onSubmitted: (_) => _speakText(),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _performGreeting,
                            icon: Icon(Icons.waving_hand),
                            label: Text('Greet'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _performGoodbye,
                            icon: Icon(Icons.exit_to_app),
                            label: Text('Goodbye'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Navigation Controls
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Navigation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      if (_locations.isEmpty)
                        Text('No saved locations found')
                      else
                        ...(_locations
                            .map(
                              (location) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(location)),
                                    ElevatedButton(
                                      onPressed: () => _temi.goTo(location),
                                      child: Text('Go To'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList()),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _temi.followMe(),
                            icon: Icon(Icons.follow_the_signs),
                            label: Text('Follow Me'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _temi.stopMovement(),
                            icon: Icon(Icons.stop_circle),
                            label: Text('Stop Navigation'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Robot Settings
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Robot Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => {},
                            icon: Icon(Icons.bedtime),
                            label: Text('Sleep Mode'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => {},
                            icon: Icon(Icons.wb_sunny),
                            label: Text('Wake Up'),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _updateRobotInfo,
                            icon: Icon(Icons.refresh),
                            label: Text('Refresh Status'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // final health = await _temi.getHealthStatus();
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: Text('Robot Health'),
                                      content: Text(""),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: Text('OK'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            icon: Icon(Icons.health_and_safety),
                            label: Text('Health Check'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
