import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'temi_method_channel.dart';

abstract class TemiPlatform extends PlatformInterface {
  /// Constructs a TemiPlatform.
  TemiPlatform() : super(token: _token);

  static final Object _token = Object();

  static TemiPlatform _instance = MethodChannelTemi();

  /// The default instance of [TemiPlatform] to use.
  ///
  /// Defaults to [MethodChannelTemi].
  static TemiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TemiPlatform] when
  /// they register themselves.
  static set instance(TemiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> skidJoy(double x, double y, bool smart) {
    throw UnimplementedError('skidJoy() has not been implemented.');
  }

  Future<void> startDetectionListening() {
    throw UnimplementedError('startListening() has not been implemented.');
  }

  Future<void> stopDetectionListening() {
    throw UnimplementedError('stopListening() has not been implemented.');
  }

  void setOnRobotReadyListener(Function(bool isReady) callback) {
    throw UnimplementedError(
      'setOnRobotReadyListener() has not been implemented.',
    );
  }

  void setOnUserInteractionListener(Function(bool isInteracting) callback) {
    throw UnimplementedError(
      'setOnUserInteractionListener() has not been implemented.',
    );
  }

  void setOnDetectionStateChangedListener(Function(int state) callback) {
    throw UnimplementedError(
      'setOnDetectionStateChangedListener() has not been implemented.',
    );
  }

  void setOnGoToLocationStatusChangedListener(
    Function(
      String location,
      String status,
      int descriptionId,
      String description,
    )
    callback,
  ) {
    throw UnimplementedError(
      'setOnGoToLocationStatusChangedListener() has not been implemented.',
    );
  }

  void setOnTtsStatusChangedListener(
    Function(String id, String text, String status) callback,
  ) {
    throw UnimplementedError(
      'setOnTtsStatusChangedListener() has not been implemented.',
    );
  }

  void setOnTonFaceRecognizedListener(
    Function(Map<dynamic, dynamic> faceData) callback,
  ) {
    throw UnimplementedError(
      'setOnTonFaceRecognizedListener() has not been implemented.',
    );
  }

  Future<bool> speak(String text) {
    throw UnimplementedError('speak() has not been implemented.');
  }

  Future<bool> followMe() {
    throw UnimplementedError('followMe() has not been implemented.');
  }

  Future<bool> stopMovement() {
    throw UnimplementedError('stopMovement() has not been implemented.');
  }

  Future<List<String>> getLocations() {
    throw UnimplementedError('getLocations() has not been implemented.');
  }

  Future<bool> saveLocation(String name) {
    throw UnimplementedError('saveLocation() has not been implemented.');
  }

  Future<bool> deleteLocation(String name) {
    throw UnimplementedError('deleteLocation() has not been implemented.');
  }

  Future<bool> gotoLocation(String location) {
    throw UnimplementedError('gotoLocation() has not been implemented.');
  }

  Future<bool> setPrivacyMode(bool enabled) {
    throw UnimplementedError('setPrivacyMode() has not been implemented.');
  }

  Future<bool> isPrivacyModeEnabled() {
    throw UnimplementedError(
      'isPrivacyModeEnabled() has not been implemented.',
    );
  }

  Future<Map<String, dynamic>> getRobotInfo() {
    throw UnimplementedError('getRobotInfo() has not been implemented.');
  }

  Future<int> getBatteryLevel() {
    throw UnimplementedError('getBatteryLevel() has not been implemented.');
  }

  Future<bool> setDetectionMode(bool enabled) {
    throw UnimplementedError('setDetectionMode() has not been implemented.');
  }

  Future<bool> setTrackUser(bool enabled) {
    throw UnimplementedError('setTrackUser() has not been implemented.');
  }

  Future<bool> registerFace(String fileUri, String userId, String userName) {
    throw UnimplementedError('registerFace() has not been implemented.');
  }

  Future<bool> startFaceRecognition() {
    throw UnimplementedError(
      'startFaceRecognition() has not been implemented.',
    );
  }

  Future<bool> stopFaceRecognition() {
    throw UnimplementedError('stopFaceRecognition() has not been implemented.');
  }
}
