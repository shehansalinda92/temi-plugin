import 'temi_platform_interface.dart';

class Temi {
  Future<String?> getPlatformVersion() {
    return TemiPlatform.instance.getPlatformVersion();
  }

  Future<bool> skidJoy(double x, double y, {bool smart = false}) {
    x = x.clamp(-1.0, 1.0);
    y = y.clamp(-1.0, 1.0);
    return TemiPlatform.instance.skidJoy(x, y, smart);
  }

  Future<bool> moveForward({double speed = 0.5}) {
    return skidJoy(0, speed);
  }

  Future<bool> moveBackward({double speed = 0.5}) {
    return skidJoy(0, -speed);
  }

  Future<bool> turnLeft({double speed = 0.5}) {
    return skidJoy(-speed, 0);
  }

  Future<bool> turnRight({double speed = 0.5}) {
    return skidJoy(speed, 0);
  }

  Future<bool> stop() {
    return skidJoy(0, 0);
  }

  Future<void> startDetectionListening() {
    return TemiPlatform.instance.startDetectionListening();
  }

  Future<void> stopDetectionListening() {
    return TemiPlatform.instance.stopDetectionListening();
  }

  void setOnRobotReadyListener(Function(bool isReady) callback) {
    TemiPlatform.instance.setOnRobotReadyListener(callback);
  }

  void setOnUserInteractionListener(Function(bool isInteracting) callback) {
    TemiPlatform.instance.setOnUserInteractionListener(callback);
  }

  void setOnDetectionStateChangedListener(Function(int state) callback) {
    TemiPlatform.instance.setOnDetectionStateChangedListener(callback);
  }

  void setOnGoToLocationStatusChangedListener(
      Function(String location, String status, int descriptionId, String description) callback
      ) {
    TemiPlatform.instance.setOnGoToLocationStatusChangedListener(callback);
  }

  void setOnTtsStatusChangedListener(
      Function(String id, String text, String status) callback
      ) {
    TemiPlatform.instance.setOnTtsStatusChangedListener(callback);
  }

  Future<bool> speak(String text) {
    return TemiPlatform.instance.speak(text);
  }

  Future<bool> goTo(String location) {
    return TemiPlatform.instance.goTo(location);
  }

  Future<bool> followMe() {
    return TemiPlatform.instance.followMe();
  }

  Future<bool> stopMovement() {
    return TemiPlatform.instance.stopMovement();
  }

  Future<List<String>> getLocations() {
    return TemiPlatform.instance.getLocations();
  }

  Future<bool> saveLocation(String name) {
    return TemiPlatform.instance.saveLocation(name);
  }

  Future<bool> deleteLocation(String name) {
    return TemiPlatform.instance.deleteLocation(name);
  }

  Future<bool> setPrivacyMode(bool enabled) {
    return TemiPlatform.instance.setPrivacyMode(enabled);
  }

  Future<bool> isPrivacyModeEnabled() {
    return TemiPlatform.instance.isPrivacyModeEnabled();
  }

  Future<Map<String, dynamic>> getRobotInfo() {
    return TemiPlatform.instance.getRobotInfo();
  }

  Future<int> getBatteryLevel() {
    return TemiPlatform.instance.getBatteryLevel();
  }

  Future<bool> setDetectionMode(bool enabled) {
    return TemiPlatform.instance.setDetectionMode(enabled);
  }

  Future<bool> setTrackUser(bool enabled) {
    return TemiPlatform.instance.setTrackUser(enabled);
  }

  void setupAllListeners({
    Function(bool)? onRobotReady,
    Function(bool)? onUserInteraction,
    Function(int)? onDetectionStateChanged,
    Function(String, String, int, String)? onGoToLocationStatusChanged,
    Function(String, String, String)? onTtsStatusChanged,
  }) {
    if (onRobotReady != null) setOnRobotReadyListener(onRobotReady);
    if (onUserInteraction != null) setOnUserInteractionListener(onUserInteraction);
    if (onDetectionStateChanged != null) setOnDetectionStateChangedListener(onDetectionStateChanged);
    if (onGoToLocationStatusChanged != null) setOnGoToLocationStatusChangedListener(onGoToLocationStatusChanged);
    if (onTtsStatusChanged != null) setOnTtsStatusChangedListener(onTtsStatusChanged);
  }

  Future<void> initialize({
    bool enableDetection = true,
    bool enableUserTracking = false,
    bool privacyMode = false,
  }) async {
    await startDetectionListening();
    await setDetectionMode(enableDetection);
    await setTrackUser(enableUserTracking);
    await setPrivacyMode(privacyMode);
  }


  Future<void> dispose() async {
    await stopDetectionListening();
  }


  Future<bool> moveForwardLeft({double speed = 0.5}) {
    final normalizedSpeed = speed * 0.707;
    return skidJoy(-normalizedSpeed, normalizedSpeed);
  }


  Future<bool> moveForwardRight({double speed = 0.5}) {
    final normalizedSpeed = speed * 0.707;
    return skidJoy(normalizedSpeed, normalizedSpeed);
  }


  Future<bool> moveBackwardLeft({double speed = 0.5}) {
    final normalizedSpeed = speed * 0.707;
    return skidJoy(-normalizedSpeed, -normalizedSpeed);
  }


  Future<bool> moveBackwardRight({double speed = 0.5}) {
    final normalizedSpeed = speed * 0.707;
    return skidJoy(normalizedSpeed, -normalizedSpeed);
  }

  Future<void> executeMovementSequence(List<Future<bool> Function()> movements, {Duration delay = const Duration(milliseconds: 500)}) async {
    for (final movement in movements) {
      await movement();
      await Future.delayed(delay);
    }
    await stop();
  }
}