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
}
