// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/party_masters/models/party_master_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';

class PartyMasterCard extends StatelessWidget {
  const PartyMasterCard({
    super.key,
    required this.party,
    required this.onEdit,
    required this.onDelete,
    required this.isExpanded,
    required this.onTap,
  });

  final PartyMasterDm party;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
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
                    tablet ? AppSpaces.h12 : AppSpaces.h8,
                    // Delete Button
                    Material(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                      child: InkWell(
                        onTap: () => _showDeleteDialog(context, tablet),
                        borderRadius: BorderRadius.circular(tablet ? 10 : 8),
                        child: Container(
                          padding: tablet
                              ? AppPaddings.combined(
                                  horizontal: 10,
                                  vertical: 8,
                                )
                              : AppPaddings.combined(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                          child: Icon(
                            Icons.delete_rounded,
                            size: tablet ? 20 : 18,
                            color: Colors.red,
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

  void _showDeleteDialog(BuildContext context, bool tablet) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tablet ? 20 : 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: tablet ? 520 : double.infinity,
          constraints: BoxConstraints(
            maxWidth: tablet ? 520 : MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: kColorWhite,
            borderRadius: BorderRadius.circular(tablet ? 20 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 24, vertical: 20)
                    : AppPaddings.combined(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(tablet ? 20 : 16),
                    topRight: Radius.circular(tablet ? 20 : 16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: AppPaddings.p10,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(tablet ? 12 : 10),
                      ),
                      child: Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                        size: tablet ? 26 : 22,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: Text(
                        'Delete Party',
                        style: TextStyles.kSemiBoldOutfit(
                          fontSize: tablet
                              ? FontSizes.k22FontSize
                              : FontSizes.k18FontSize,
                          color: kColorTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: tablet ? AppPaddings.p24 : AppPaddings.p20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure you want to delete "${party.accountName}"?',
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k16FontSize
                            : FontSizes.k14FontSize,
                        color: kColorTextPrimary,
                      ),
                    ),
                    tablet ? AppSpaces.v8 : AppSpaces.v6,
                    Text(
                      'This action cannot be undone.',
                      style: TextStyles.kRegularOutfit(
                        fontSize: tablet
                            ? FontSizes.k14FontSize
                            : FontSizes.k12FontSize,
                        color: kColorDarkGrey,
                      ),
                    ),
                    tablet ? AppSpaces.v24 : AppSpaces.v20,
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: kColorLightGrey,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  tablet ? 12 : 10,
                                ),
                              ),
                              padding: AppPaddings.combined(
                                vertical: tablet ? 16 : 14,
                                horizontal: 0,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyles.kMediumOutfit(
                                color: kColorDarkGrey,
                                fontSize: tablet
                                    ? FontSizes.k16FontSize
                                    : FontSizes.k14FontSize,
                              ),
                            ),
                          ),
                        ),
                        tablet ? AppSpaces.h16 : AppSpaces.h12,
                        Expanded(
                          child: AppButton(
                            title: 'Delete',
                            buttonColor: Colors.red,
                            titleColor: kColorWhite,
                            titleSize: tablet
                                ? FontSizes.k16FontSize
                                : FontSizes.k14FontSize,
                            buttonHeight: tablet ? 54 : 48,
                            onPressed: () {
                              Get.back();
                              onDelete();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
