import 'package:flutter/material.dart';
import 'package:smart_banner/src/core/banner_style.dart';
import 'package:smart_banner/src/theme/theme.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AdaptiveActionButton extends StatelessWidget {
  const AdaptiveActionButton({
    super.key,
    required this.label,
    required this.style,
    required this.url,
    required this.storeUrl,
  });

  final String label;
  final BannerStyle style;
  final String? url;
  final String storeUrl;

  @override
  Widget build(BuildContext context) {
    final theme = SmartBannerTheme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.lightBlue,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: TextButton(
        onPressed: _handleOnPressed,
        child: Text(
          label,
          style: theme.buttonTextStyle.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _handleOnPressed() async {
    final localUrl = url;
    if (localUrl != null) {
      final canLaunch = await canLaunchUrlString(localUrl);
      if (canLaunch) {
        await launchUrlString(localUrl);
      } else {
        await launchUrlString(storeUrl);
      }
    } else {
      await launchUrlString(storeUrl);
    }
  }
}
