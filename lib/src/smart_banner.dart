import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../smart_banner.dart';
import 'theme/theme.dart';
import 'utils/separated_text_span.dart';

const kBannerHeight = 80.0;

class SmartBanner extends StatelessWidget {
  const SmartBanner({
    super.key,
    required this.properties,
    this.style = BannerStyle.adaptive,
  });

  final BannerProperties properties;

  /// Used to enforce a specific style no matter the platform you are on.
  final BannerStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = SmartBannerTheme.of(context);
    final effectiveLang = properties.appStoreLanguage ??
        Localizations.localeOf(context).languageCode;

    return Material(
      color: theme.backgroundColor,
      shadowColor: theme.shadowColor,
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        height: kBannerHeight,
        width: double.maxFinite,
        child: Row(
          children: [
            _CloseButton(onClose: properties.onClose),
            const SizedBox(width: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 57, maxWidth: 57),
              child: properties.icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TitleAndDecription(
                title: properties.title,
                store: properties.platformProperties.storeText,
                price: properties.platformProperties.priceText,
                author: properties.author,
              ),
            ),
            _ViewButton(
              lang: effectiveLang,
              label: properties.buttonLabel,
              url: properties.platformProperties.url,
              appId: properties.platformProperties.appId,
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({
    required this.onClose,
  });

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        SmartBannerScaffold.hideBanner(context);
        onClose?.call();
      },
      iconSize: 18,
      icon: const Text('×'),
    );
  }
}

class _TitleAndDecription extends StatelessWidget {
  const _TitleAndDecription({
    required this.title,
    required this.price,
    required this.store,
    required this.author,
  });

  final String title;
  final String? price;
  final String? store;
  final String? author;

  @override
  Widget build(BuildContext context) {
    final theme = SmartBannerTheme.of(context);
    final localAuthor = author;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.titleTextStyle,
        ),
        if (localAuthor != null) Text(localAuthor),
        Text.rich(
          SeparatedTextSpan(
            separator: const TextSpan(text: ' - '),
            children: [
              if (price != null) TextSpan(text: price),
              if (store != null) TextSpan(text: store),
            ],
          ),
          style: theme.descriptionTextStyle,
        ),
      ],
    );
  }
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({
    required this.lang,
    required this.label,
    required this.url,
    required this.appId,
  });

  final String lang;
  final String label;
  final String? url;
  final String appId;

  @override
  Widget build(BuildContext context) {
    final theme = SmartBannerTheme.of(context);
    return TextButton(
      onPressed: _handleOnPressed,
      child: Text(
        label,
        style: theme.buttonTextStyle,
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
        await launchUrlString(_createUrl());
      }
    } else {
      await launchUrlString(_createUrl());
    }
  }

  String _createUrl() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://play.google.com/store/apps/details?id=$appId&hl=$lang';
    } else {
      return 'https://apps.apple.com/$lang/app/id$appId';
    }
  }
}
