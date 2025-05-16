import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'temi_platform_interface.dart';

/// An implementation of [TemiPlatform] that uses method channels.
class MethodChannelTemi extends TemiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('temi');

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
}
