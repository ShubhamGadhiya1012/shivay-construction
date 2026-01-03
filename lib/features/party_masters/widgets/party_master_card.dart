// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';

class PartyMasterCard extends StatelessWidget {
  const PartyMasterCard({
    super.key,
    required this.party,
    required this.onEdit,
    required this.isExpanded,
    required this.onTap,
  });

  final PartyMasterDm party;
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
                        party.accountName,
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

                if (party.printName.isNotEmpty) ...[
                  _buildInfoRow(
                    label: 'Print Name',
                    value: party.printName,
                    tablet: tablet,
                  ),
                  tablet ? AppSpaces.v12 : AppSpaces.v10,
                ],

                if (party.location.isNotEmpty) ...[
                  _buildInfoRow(
                    label: 'Location',
                    value: party.location,
                    tablet: tablet,
                  ),
                  tablet ? AppSpaces.v12 : AppSpaces.v10,
                ],

                if (party.addressLine1.isNotEmpty ||
                    party.addressLine2.isNotEmpty ||
                    party.addressLine3.isNotEmpty) ...[
                  _buildInfoRow(
                    label: 'Address',
                    value: [
                      if (party.addressLine1.isNotEmpty) party.addressLine1,
                      if (party.addressLine2.isNotEmpty) party.addressLine2,
                      if (party.addressLine3.isNotEmpty) party.addressLine3,
                    ].join(', '),
                    tablet: tablet,
                  ),
                ],

                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tablet ? AppSpaces.v12 : AppSpaces.v10,

                      if (party.city.isNotEmpty || party.state.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (party.city.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'City',
                                  value: party.city,
                                  tablet: tablet,
                                ),
                              ),
                            if (party.city.isNotEmpty && party.state.isNotEmpty)
                              tablet ? AppSpaces.h16 : AppSpaces.h12,
                            if (party.state.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'State',
                                  value: party.state,
                                  tablet: tablet,
                                ),
                              ),
                          ],
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (party.pinCode.isNotEmpty) ...[
                        _buildInfoRow(
                          label: 'Pin Code',
                          value: party.pinCode,
                          tablet: tablet,
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (party.personName.isNotEmpty) ...[
                        _buildInfoRow(
                          label: 'Contact Person',
                          value: party.personName,
                          tablet: tablet,
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (party.mobile.isNotEmpty) ...[
                        _buildInfoRow(
                          label: 'Mobile',
                          value: party.mobile,
                          tablet: tablet,
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (party.phone1.isNotEmpty ||
                          party.phone2.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (party.phone1.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'Phone 1',
                                  value: party.phone1,
                                  tablet: tablet,
                                ),
                              ),
                            if (party.phone1.isNotEmpty &&
                                party.phone2.isNotEmpty)
                              tablet ? AppSpaces.h16 : AppSpaces.h12,
                            if (party.phone2.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'Phone 2',
                                  value: party.phone2,
                                  tablet: tablet,
                                ),
                              ),
                          ],
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (party.gstNumber.isNotEmpty ||
                          party.pan.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (party.gstNumber.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'GST Number',
                                  value: party.gstNumber,
                                  tablet: tablet,
                                ),
                              ),
                            if (party.gstNumber.isNotEmpty &&
                                party.pan.isNotEmpty)
                              tablet ? AppSpaces.h16 : AppSpaces.h12,
                            if (party.pan.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'PAN Number',
                                  value: party.pan,
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
