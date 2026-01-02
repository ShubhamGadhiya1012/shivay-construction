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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
                  color: kColorWhite.withOpacity(0.8),
                ),
              );
            } else if (snapshot.hasError) {
              return Text(
                "Error loading version",
                style: TextStyles.kRegularOutfit(
                  fontSize: tablet
                      ? FontSizes.k18FontSize
                      : FontSizes.k14FontSize,
                  color: kColorWhite.withOpacity(0.8),
                ),
              );
            } else {
              return Text(
                'v${snapshot.data}',
                style: TextStyles.kRegularOutfit(
                  fontSize: tablet
                      ? FontSizes.k18FontSize
                      : FontSizes.k14FontSize,
                  color: kColorWhite,
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
              fontSize: tablet ? FontSizes.k16FontSize : FontSizes.k12FontSize,
              color: kColorWhite.withOpacity(0.8),
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
                      color: kColorWhite,
                    ).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: kColorWhite,
                    ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final Uri url = Uri.parse("https://jinee.in/Default.aspx");
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

        tablet ? AppSpaces.v20 : AppSpaces.v16,
      ],
    );
  }
}
