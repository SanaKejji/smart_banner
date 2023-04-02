import 'package:flutter/material.dart';
import 'package:smart_banner/src/core/banner_properties.dart';
import 'package:smart_banner/src/core/banner_style.dart';
import 'package:smart_banner/src/theme/theme.dart';
import 'package:smart_banner/src/utils/separated_text_span.dart';
import 'package:smart_banner/src/utils/target_platform_extension.dart';
import 'package:smart_banner/src/widgets/adaptive_action_button.dart';
import 'package:smart_banner/src/widgets/adaptive_close_button.dart';
import 'package:url_launcher/url_launcher_string.dart';

// const kBannerHeight = 150.0;

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
    final effectiveLang =
        properties.appStoreLanguage ?? Localizations.localeOf(context).languageCode;

    final platformProperties = properties.getPropertiesFromStyle(
      context,
      style,
    );
    final targetPlatform = Theme.of(context).platform;

    return Material(
      color: theme.backgroundColor,
      shadowColor: theme.shadowColor,
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: (targetPlatform.isAndroid || targetPlatform.isIOS) ? 90 : 150,
        width: double.maxFinite,
        child: Row(
          children: [
            AdaptiveCloseButton(onClose: properties.onClose),
            const SizedBox(width: 5),
            platformProperties.icon,
            const SizedBox(width: 12),
            Expanded(
              child: _TitleAndDescription(
                title: properties.title,
                store: platformProperties.storeText,
                price: platformProperties.priceText,
                author: properties.author,
              ),
            ),
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              if (targetPlatform.isAndroid || targetPlatform.isDesktop)
                GestureDetector(
                  onTap: () {
                    _handleOnPressed(
                        storeUrl: properties.androidProperties.createStoreUrl(effectiveLang),
                        url: properties.androidProperties.url);
                  },
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/play-store-logo.png',
                            package: 'smart_banner',
                            height: 30,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'GET IT ON',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                              Text(
                                'Google Play',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              if (targetPlatform.isAndroid || targetPlatform.isDesktop)
                const SizedBox(
                  width: 5,
                ),
              if (targetPlatform.isIOS || targetPlatform.isDesktop)
                GestureDetector(
                  onTap: () {
                    _handleOnPressed(
                      storeUrl: properties.iosProperties.createStoreUrl(effectiveLang),
                      url: properties.iosProperties.url,
                    );
                  },
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/apple.png',
                            package: 'smart_banner',
                            height: 30,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Download on the',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                              Text(
                                'App Store',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
            ])
          ],
        ),
      ),
    );
  }
}

Future<void> _handleOnPressed({String? url, required String storeUrl}) async {
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

class _TitleAndDescription extends StatelessWidget {
  const _TitleAndDescription({
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
        if (localAuthor != null)
          Text(
            localAuthor,
            style: theme.descriptionTextStyle,
          ),
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
