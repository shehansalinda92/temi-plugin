import 'package:flutter_test/flutter_test.dart';
import 'package:temi/temi.dart';
import 'package:temi/temi_platform_interface.dart';
import 'package:temi/temi_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTemiPlatform
    with MockPlatformInterfaceMixin
    implements TemiPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TemiPlatform initialPlatform = TemiPlatform.instance;

  test('$MethodChannelTemi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTemi>());
  });

  test('getPlatformVersion', () async {
    Temi temiPlugin = Temi();
    MockTemiPlatform fakePlatform = MockTemiPlatform();
    TemiPlatform.instance = fakePlatform;

    expect(await temiPlugin.getPlatformVersion(), '42');
  });
}
