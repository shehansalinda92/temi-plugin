import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'temi_platform_interface.dart';

/// An implementation of [TemiPlatform] that uses method channels.
class MethodChannelTemi extends TemiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('temi');

  // Callback functions for robot events
  Function(bool)? _onRobotReadyCallback;
  Function(bool)? _onUserInteractionCallback;
  Function(int)? _onDetectionStateChangedCallback;
  Function(String, String, int, String)? _onGoToLocationStatusChangedCallback;
  Function(String, String, String)? _onTtsStatusChangedCallback;
  // Function(Map<dynamic, dynamic> faceData)? _onTonFaceRecognizedChangedCallback;

  MethodChannelTemi() {
    // Set up method call handler for receiving events from native side
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handle method calls from the native side
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onRobotReady':
        _onRobotReadyCallback?.call(call.arguments['isReady'] ?? false);
        break;
      case 'onUserInteraction':
        _onUserInteractionCallback?.call(
          call.arguments['isInteracting'] ?? false,
        );
        break;
      case 'onDetectionStateChanged':
        _onDetectionStateChangedCallback?.call(call.arguments['state'] ?? 0);
        break;
      case 'onGoToLocationStatusChanged':
        _onGoToLocationStatusChangedCallback?.call(
          call.arguments['location'] ?? '',
          call.arguments['status'] ?? '',
          call.arguments['descriptionId'] ?? 0,
          call.arguments['description'] ?? '',
        );
        break;
      case 'onTtsStatusChanged':
        _onTtsStatusChangedCallback?.call(
          call.arguments['id'] ?? '',
          call.arguments['text'] ?? '',
          call.arguments['status'] ?? '',
        );
        break;
      default:
        debugPrint('Unknown method call: ${call.method}');
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<bool> skidJoy(double x, double y, bool smart) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('skidJoy', {
        'x': x,
        'y': y,
        'smart': smart,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error calling skidJoy: ${e.message}');
      return false;
    }
  }

  @override
  Future<void> startDetectionListening() async {
    try {
      await methodChannel.invokeMethod('startDetectionListening');
    } on PlatformException catch (e) {
      debugPrint('Error starting listening: ${e.message}');
    }
  }

  @override
  Future<void> stopDetectionListening() async {
    try {
      await methodChannel.invokeMethod('stopDetectionListening');
    } on PlatformException catch (e) {
      debugPrint('Error stopping listening: ${e.message}');
    }
  }

  @override
  void setOnRobotReadyListener(Function(bool isReady) callback) {
    _onRobotReadyCallback = callback;
  }

  @override
  void setOnUserInteractionListener(Function(bool isInteracting) callback) {
    _onUserInteractionCallback = callback;
  }

  @override
  void setOnDetectionStateChangedListener(Function(int state) callback) {
    _onDetectionStateChangedCallback = callback;
  }

  @override
  void setOnGoToLocationStatusChangedListener(
    Function(
      String location,
      String status,
      int descriptionId,
      String description,
    )
    callback,
  ) {
    _onGoToLocationStatusChangedCallback = callback;
  }

  @override
  void setOnTtsStatusChangedListener(
    Function(String id, String text, String status) callback,
  ) {
    _onTtsStatusChangedCallback = callback;
  }

  @override
  void setOnTonFaceRecognizedListener(
    Function(Map<dynamic, dynamic> faceData) callback,
  ) {
    //_onTonFaceRecognizedChangedCallback = callback;
  }

  @override
  Future<bool> speak(String text) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('speak', {
        'text': text,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error calling speak: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> registerFace(
    String fileUri,
    String userId,
    String userName,
  ) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('registerFace', {
        'fileUri': fileUri,
        'userId': userId,
        'username': userName,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error adding face: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> startFaceRecognition() async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'startFaceRecognition',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error calling goTo: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> stopFaceRecognition() async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'stopFaceRecognition',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error calling goTo: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> gotoLocation(String location) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('gotoLocation', {
        'location': location,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error calling goTo: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> followMe() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('followMe');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error calling followMe: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> stopMovement() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('stopMovement');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error calling stopMovement: ${e.message}');
      return false;
    }
  }

  @override
  Future<List<String>> getLocations() async {
    try {
      final result = await methodChannel.invokeMethod('getLocations');
      if (result is List) {
        return result.cast<String>();
      }
      return [];
    } on PlatformException catch (e) {
      debugPrint('Error calling getLocations: ${e.message}');
      return [];
    }
  }

  @override
  Future<bool> saveLocation(String name) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('saveLocation', {
        'name': name,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error calling saveLocation: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> deleteLocation(String name) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('deleteLocation', {
        'name': name,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error calling deleteLocation: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> setPrivacyMode(bool enabled) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('setPrivacyMode', {
        'enabled': enabled,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error calling setPrivacyMode: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> isPrivacyModeEnabled() async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'isPrivacyModeEnabled',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error calling isPrivacyModeEnabled: ${e.message}');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getRobotInfo() async {
    try {
      final result = await methodChannel.invokeMethod('getRobotInfo');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return {};
    } on PlatformException catch (e) {
      debugPrint('Error calling getRobotInfo: ${e.message}');
      return {};
    }
  }

  @override
  Future<int> getBatteryLevel() async {
    try {
      final result = await methodChannel.invokeMethod<int>('getBatteryLevel');
      return result ?? 0;
    } on PlatformException catch (e) {
      debugPrint('Error calling getBatteryLevel: ${e.message}');
      return 0;
    }
  }

  @override
  Future<bool> setDetectionMode(bool enabled) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'setDetectionMode',
        {'enabled': enabled},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error calling setDetectionMode: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> setTrackUser(bool enabled) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('setTrackUser', {
        'enabled': enabled,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error calling setTrackUser: ${e.message}');
      return false;
    }
  }
}
