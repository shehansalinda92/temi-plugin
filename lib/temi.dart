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
}
