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
  double _xValue = 0.9;
  double _yValue = 0.9;
  bool _smartMode = false;

  Future<void> _moveRobot() async {
    final success = await _temi.skidJoy(_xValue, _yValue, smart: _smartMode);
    if (success) {
      print('Robot moving with x: $_xValue, y: $_yValue, smart: $_smartMode');
    } else {
      print('Failed to move robot');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Temi Flutter Plugin')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('X: ${_xValue.toStringAsFixed(2)}'),
              Slider(
                value: _xValue,
                min: -1.0,
                max: 1.0,
                onChanged: (value) {
                  setState(() {
                    _xValue = value;
                  });
                },
                onChangeEnd: (_) => _moveRobot(),
              ),
              SizedBox(height: 20),
              Text('Y: ${_yValue.toStringAsFixed(2)}'),
              Slider(
                value: _yValue,
                min: -1.0,
                max: 1.0,
                onChanged: (value) {
                  setState(() {
                    _yValue = value;
                  });
                },
                onChangeEnd: (_) => _moveRobot(),
              ),
              SizedBox(height: 20),
              SwitchListTile(
                title: Text('Smart Mode'),
                value: _smartMode,
                onChanged: (value) {
                  setState(() {
                    _smartMode = value;
                  });
                },
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _temi.moveForward(),
                    child: Text('Forward'),
                  ),
                  ElevatedButton(
                    onPressed: () => _temi.moveBackward(),
                    child: Text('Backward'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _temi.turnLeft(),
                    child: Text('Turn Left'),
                  ),
                  ElevatedButton(
                    onPressed: () => _temi.turnRight(),
                    child: Text('Turn Right'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _temi.stop(),
                child: Text('STOP'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
