// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/site%20master/models/site_master_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class SiteMasterCard extends StatelessWidget {
  const SiteMasterCard({
    super.key,
    required this.site,
    required this.onEdit,
    required this.isExpanded,
    required this.onTap,
  });

  final SiteMasterDm site;
  final VoidCallback onEdit;
  final bool isExpanded;
  final VoidCallback onTap;

  Widget _buildInfoRow({
    required String label,
    required String value,
    required bool tablet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.kMediumOutfit(
            fontSize: tablet ? FontSizes.k14FontSize : FontSizes.k12FontSize,
            color: kColorDarkGrey,
          ),
        ),
        tablet ? AppSpaces.v4 : AppSpaces.v2,
        Text(
          value,
          style: TextStyles.kSemiBoldOutfit(
            fontSize: tablet ? FontSizes.k15FontSize : FontSizes.k14FontSize,
            color: kColorTextPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);

    return Container(
      margin: tablet
          ? AppPaddings.custom(bottom: 12)
          : AppPaddings.custom(bottom: 10),
      decoration: BoxDecoration(
        color: kColorWhite,
        borderRadius: BorderRadius.circular(tablet ? 14 : 12),
        border: Border.all(color: kColorLightGrey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: kColorPrimary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tablet ? 14 : 12),
          child: Padding(
            padding: tablet
                ? AppPaddings.combined(horizontal: 18, vertical: 16)
                : AppPaddings.combined(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        site.siteName,
                        style: TextStyles.kBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k20FontSize
                              : FontSizes.k18FontSize,
                          color: kColorPrimary,
                        ),
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h8,
                    Material(
                      color: kColorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                      child: InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                        child: Container(
                          padding: tablet
                              ? AppPaddings.combined(
                                  horizontal: 12,
                                  vertical: 8,
                                )
                              : AppPaddings.combined(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: tablet ? 18 : 16,
                                color: kColorPrimary,
                              ),
                              AppSpaces.h6,
                              Text(
                                'Edit',
                                style: TextStyles.kSemiBoldOutfit(
                                  fontSize: tablet
                                      ? FontSizes.k15FontSize
                                      : FontSizes.k14FontSize,
                                  color: kColorPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AppSpaces.h8,
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: tablet ? 28 : 24,
                        color: kColorPrimary,
                      ),
                    ),
                  ],
                ),

                tablet ? AppSpaces.v16 : AppSpaces.v12,
                Divider(height: 1, color: kColorLightGrey.withOpacity(0.5)),
                tablet ? AppSpaces.v16 : AppSpaces.v12,

                if (site.address1.isNotEmpty) ...[
                  _buildInfoRow(
                    label: 'Address',
                    value: [
                      if (site.address1.isNotEmpty) site.address1,
                      if (site.address2.isNotEmpty) site.address2,
                    ].join(', '),
                    tablet: tablet,
                  ),
                  tablet ? AppSpaces.v12 : AppSpaces.v10,
                ],

                if (site.city.isNotEmpty || site.state.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (site.city.isNotEmpty)
                        Expanded(
                          child: _buildInfoRow(
                            label: 'City',
                            value: site.city,
                            tablet: tablet,
                          ),
                        ),
                      if (site.city.isNotEmpty && site.state.isNotEmpty)
                        tablet ? AppSpaces.h16 : AppSpaces.h12,
                      if (site.state.isNotEmpty)
                        Expanded(
                          child: _buildInfoRow(
                            label: 'State',
                            value: site.state,
                            tablet: tablet,
                          ),
                        ),
                    ],
                  ),
                ],

                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tablet ? AppSpaces.v12 : AppSpaces.v10,

                      if (site.pinCode.isNotEmpty) ...[
                        _buildInfoRow(
                          label: 'Pin Code',
                          value: site.pinCode,
                          tablet: tablet,
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (site.phone.isNotEmpty || site.fax.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (site.phone.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'Phone',
                                  value: site.phone,
                                  tablet: tablet,
                                ),
                              ),
                            if (site.phone.isNotEmpty && site.fax.isNotEmpty)
                              tablet ? AppSpaces.h16 : AppSpaces.h12,
                            if (site.fax.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'Fax',
                                  value: site.fax,
                                  tablet: tablet,
                                ),
                              ),
                          ],
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (site.email.isNotEmpty) ...[
                        _buildInfoRow(
                          label: 'Email',
                          value: site.email,
                          tablet: tablet,
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (site.pan.isNotEmpty || site.gstNumber.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (site.pan.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'PAN Number',
                                  value: site.pan,
                                  tablet: tablet,
                                ),
                              ),
                            if (site.pan.isNotEmpty &&
                                site.gstNumber.isNotEmpty)
                              tablet ? AppSpaces.h16 : AppSpaces.h12,
                            if (site.gstNumber.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'GST Number',
                                  value: site.gstNumber,
                                  tablet: tablet,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
