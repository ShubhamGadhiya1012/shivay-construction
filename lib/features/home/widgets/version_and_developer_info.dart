// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/helpers/version_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class VersionAndDeveloperInfo extends StatelessWidget {
  const VersionAndDeveloperInfo({super.key, required this.tablet});

  final bool tablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tablet ? 16 : 12,
        vertical: tablet ? 16 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(color: kColorLightGrey, thickness: 1, height: 1),

          tablet ? AppSpaces.v16 : AppSpaces.v12,

          FutureBuilder<String>(
            future: VersionHelper.getVersion(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                  "Loading...",
                  style: TextStyles.kRegularOutfit(
                    fontSize: tablet
                        ? FontSizes.k18FontSize
                        : FontSizes.k14FontSize,
                    color: kColorSecondary,
                  ),
                );
              } else if (snapshot.hasError) {
                return Text(
                  "Error loading version",
                  style: TextStyles.kRegularOutfit(
                    fontSize: tablet
                        ? FontSizes.k18FontSize
                        : FontSizes.k14FontSize,
                    color: kColorSecondary,
                  ),
                );
              } else {
                return Text(
                  'v${snapshot.data}',
                  style: TextStyles.kMediumOutfit(
                    fontSize: tablet
                        ? FontSizes.k18FontSize
                        : FontSizes.k14FontSize,
                    color: kColorPrimary,
                  ),
                );
              }
            },
          ),

          AppSpaces.v4,

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyles.kRegularOutfit(
                fontSize: tablet
                    ? FontSizes.k16FontSize
                    : FontSizes.k12FontSize,
                color: kColorSecondary,
              ),
              children: [
                const TextSpan(text: 'Powered by '),
                TextSpan(
                  text: 'Jinee Infotech',
                  style:
                      TextStyles.kMediumOutfit(
                        fontSize: tablet
                            ? FontSizes.k16FontSize
                            : FontSizes.k12FontSize,
                        color: kColorPrimary,
                      ).copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: kColorPrimary,
                      ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final Uri url = Uri.parse(
                        "https://jinee.in/Default.aspx",
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                ),
              ],
            ),
          ),

          tablet ? AppSpaces.v12 : AppSpaces.v8,
        ],
      ),
    );
  }
}
