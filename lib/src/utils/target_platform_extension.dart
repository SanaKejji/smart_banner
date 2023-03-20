import 'package:flutter/foundation.dart';

extension SupportedPlatformExtension on TargetPlatform {
  bool get isAndroid => this == TargetPlatform.android;
  bool get isIOS => this == TargetPlatform.iOS;
  bool get isWindows => this == TargetPlatform.windows;
  bool get isMac => this == TargetPlatform.macOS;
  bool get isLinux => this == TargetPlatform.linux;
  bool get isDesktop => isLinux || isMac || isWindows;
  bool get isSupported => isAndroid || isIOS;
}
