import 'package:flutter/material.dart';
import 'package:smart_banner/src/utils/target_platform_extension.dart';

enum BannerStyle {
  adaptive,
  android,
  ios,
}

extension PlatformStyleExtension on BannerStyle {
  bool isAndroid(BuildContext context) {
    final targetPlatform = Theme.of(context).platform;
    switch (this) {
      case BannerStyle.adaptive:
        return targetPlatform.isAndroid;
      case BannerStyle.android:
        return true;
      case BannerStyle.ios:
        return false;
      default:
        return true;
    }
  }
}
