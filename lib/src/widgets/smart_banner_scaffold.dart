import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_banner/src/core/banner_position.dart';
import 'package:smart_banner/src/core/banner_properties.dart';
import 'package:smart_banner/src/core/banner_style.dart';
import 'package:smart_banner/src/theme/theme.dart';
import 'package:smart_banner/src/theme/theme_data.dart';
import 'package:smart_banner/src/utils/target_platform_extension.dart';
import 'package:smart_banner/src/widgets/smart_banner.dart';

const _kAnimationDuration = Duration(milliseconds: 300);

class SmartBannerScaffold extends StatefulWidget {
  const SmartBannerScaffold({
    super.key,
    required this.child,
    required this.properties,
    this.position = BannerPosition.top,
    this.style = BannerStyle.adaptive,
    this.animationDuration = _kAnimationDuration,
    this.animationCurve = Curves.easeInOut,
  });

  final Widget child;

  /// Position of the banner.
  final BannerPosition position;

  /// Used to force a specific style.
  final BannerStyle style;

  final BannerProperties properties;

  /// Duration of the sliding animation.
  final Duration animationDuration;

  /// Curve of the sliding animation.
  final Curve animationCurve;

  @override
  State<SmartBannerScaffold> createState() => SmartBannerScaffoldState();

  static SmartBannerScaffoldState of(BuildContext context) {
    final inheritedWidget = context.dependOnInheritedWidgetOfExactType<_SmartBannerScope>();
    return inheritedWidget!.state;
  }

  static SmartBannerScaffoldState? maybeOf(BuildContext context) {
    final inheritedWidget = context.dependOnInheritedWidgetOfExactType<_SmartBannerScope>();
    return inheritedWidget?.state;
  }

  static void hideBanner(BuildContext context) {
    maybeOf(context)?.hideBanner();
  }

  static void showBanner(BuildContext context) {
    maybeOf(context)?.showBanner();
  }
}

class SmartBannerScaffoldState extends State<SmartBannerScaffold> with TickerProviderStateMixin {
  late final _animationController = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
  );
  late final _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: widget.position == BannerPosition.top ? const Offset(0, -1) : const Offset(0, 1),
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ),
  );

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;
    final targetPlatform = Theme.of(context).platform;

    final effectiveTheme = _getEffectiveTheme();
    final children = <Widget>[
      AnimatedBuilder(
        animation: _offsetAnimation,
        builder: (context, _) {
          double offset = ((targetPlatform.isAndroid || targetPlatform.isIOS) ? 90 : 150) *
              _offsetAnimation.value.dy;
          if (offset < 0) offset *= -1;
          final height = ((targetPlatform.isAndroid || targetPlatform.isIOS) ? 90 : 150) - offset;

          return SizedBox(
            height: (targetPlatform.isAndroid || targetPlatform.isIOS) ? 90 : 150,
            child: SingleChildScrollView(
              child: SizedBox(
                height: (targetPlatform.isAndroid || targetPlatform.isIOS) ? 90 : 150,
                child: SmartBanner(
                  properties: widget.properties,
                  style: widget.style,
                ),
              ),
            ),
          );
        },
      ),
      SizedBox(height: MediaQuery.of(context).size.height, child: widget.child),
    ];

    return _SmartBannerScope(
      state: this,
      child: SmartBannerTheme(
        data: effectiveTheme,
        child: ListView(
          shrinkWrap: true,
          children: widget.position == BannerPosition.top ? children : children.reversed.toList(),
        ),
      ),
    );
  }

  SmartBannerThemeData _getEffectiveTheme() {
    switch (widget.style) {
      case BannerStyle.adaptive:
        return SmartBannerThemeData.adaptive(context);
      case BannerStyle.android:
        return const SmartBannerThemeData.android();
      case BannerStyle.ios:
        return const SmartBannerThemeData.ios();
    }
  }

  void hideBanner() => _animationController.forward();

  void showBanner() => _animationController.reverse();
}

class _SmartBannerScope extends InheritedWidget {
  const _SmartBannerScope({
    required this.state,
    required super.child,
  });

  final SmartBannerScaffoldState state;

  @override
  bool updateShouldNotify(_SmartBannerScope oldWidget) {
    return state != oldWidget.state;
  }
}
