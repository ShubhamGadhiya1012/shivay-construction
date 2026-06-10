// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/company_master/models/company_master_dm.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';

class CompanyMasterCard extends StatelessWidget {
  const CompanyMasterCard({
    super.key,
    required this.company,
    required this.onEdit,
    required this.onDelete,
    required this.isExpanded,
    required this.onTap,
  });

  final CompanyMasterDm company;
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

  Widget _buildSectionHeader(String title, bool tablet) {
    return Padding(
      padding: AppPaddings.custom(bottom: tablet ? 10 : 8),
      child: Text(
        title,
        style: TextStyles.kSemiBoldOutfit(
          fontSize: tablet ? FontSizes.k14FontSize : FontSizes.k12FontSize,
          color: kColorPrimary,
        ),
      ),
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
                // Header row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        company.name,
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

                // Always visible: address, city/state
                if (company.address1.isNotEmpty) ...[
                  _buildInfoRow(
                    label: 'Address',
                    value: [
                      if (company.address1.isNotEmpty) company.address1,
                      if (company.address2.isNotEmpty) company.address2,
                    ].join(', '),
                    tablet: tablet,
                  ),
                  tablet ? AppSpaces.v12 : AppSpaces.v10,
                ],

                if (company.city.isNotEmpty || company.state.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (company.city.isNotEmpty)
                        Expanded(
                          child: _buildInfoRow(
                            label: 'City',
                            value: company.city,
                            tablet: tablet,
                          ),
                        ),
                      if (company.city.isNotEmpty && company.state.isNotEmpty)
                        tablet ? AppSpaces.h16 : AppSpaces.h12,
                      if (company.state.isNotEmpty)
                        Expanded(
                          child: _buildInfoRow(
                            label: 'State',
                            value: company.state,
                            tablet: tablet,
                          ),
                        ),
                    ],
                  ),
                ],

                // Expandable section
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tablet ? AppSpaces.v12 : AppSpaces.v10,

                      if (company.zip.isNotEmpty ||
                          company.country.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (company.zip.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'ZIP Code',
                                  value: company.zip,
                                  tablet: tablet,
                                ),
                              ),
                            if (company.zip.isNotEmpty &&
                                company.country.isNotEmpty)
                              tablet ? AppSpaces.h16 : AppSpaces.h12,
                            if (company.country.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'Country',
                                  value: company.country,
                                  tablet: tablet,
                                ),
                              ),
                          ],
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (company.phone.isNotEmpty ||
                          company.fax.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (company.phone.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'Phone',
                                  value: company.phone,
                                  tablet: tablet,
                                ),
                              ),
                            if (company.phone.isNotEmpty &&
                                company.fax.isNotEmpty)
                              tablet ? AppSpaces.h16 : AppSpaces.h12,
                            if (company.fax.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'Fax',
                                  value: company.fax,
                                  tablet: tablet,
                                ),
                              ),
                          ],
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (company.email.isNotEmpty) ...[
                        _buildInfoRow(
                          label: 'Email',
                          value: company.email,
                          tablet: tablet,
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (company.mgmtEmail.isNotEmpty) ...[
                        _buildInfoRow(
                          label: 'Management Email',
                          value: company.mgmtEmail,
                          tablet: tablet,
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (company.url.isNotEmpty) ...[
                        _buildInfoRow(
                          label: 'Website URL',
                          value: company.url,
                          tablet: tablet,
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (company.pan.isNotEmpty ||
                          company.gstNumber.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (company.pan.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'PAN Number',
                                  value: company.pan,
                                  tablet: tablet,
                                ),
                              ),
                            if (company.pan.isNotEmpty &&
                                company.gstNumber.isNotEmpty)
                              tablet ? AppSpaces.h16 : AppSpaces.h12,
                            if (company.gstNumber.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'GST Number',
                                  value: company.gstNumber,
                                  tablet: tablet,
                                ),
                              ),
                          ],
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      if (company.cinNo.isNotEmpty ||
                          company.msmeNo.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (company.cinNo.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'CIN No',
                                  value: company.cinNo,
                                  tablet: tablet,
                                ),
                              ),
                            if (company.cinNo.isNotEmpty &&
                                company.msmeNo.isNotEmpty)
                              tablet ? AppSpaces.h16 : AppSpaces.h12,
                            if (company.msmeNo.isNotEmpty)
                              Expanded(
                                child: _buildInfoRow(
                                  label: 'MSME No',
                                  value: company.msmeNo,
                                  tablet: tablet,
                                ),
                              ),
                          ],
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      // Statutory Codes
                      if (company.uan.isNotEmpty ||
                          company.ptCode.isNotEmpty ||
                          company.estCode.isNotEmpty ||
                          company.pfCode.isNotEmpty ||
                          company.esiCode.isNotEmpty) ...[
                        Divider(
                          height: 1,
                          color: kColorLightGrey.withOpacity(0.5),
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                        _buildSectionHeader('Statutory Codes', tablet),
                        if (company.uan.isNotEmpty || company.ptCode.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (company.uan.isNotEmpty)
                                Expanded(
                                  child: _buildInfoRow(
                                    label: 'UAN',
                                    value: company.uan,
                                    tablet: tablet,
                                  ),
                                ),
                              if (company.uan.isNotEmpty &&
                                  company.ptCode.isNotEmpty)
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                              if (company.ptCode.isNotEmpty)
                                Expanded(
                                  child: _buildInfoRow(
                                    label: 'PT Code',
                                    value: company.ptCode,
                                    tablet: tablet,
                                  ),
                                ),
                            ],
                          ),
                        if ((company.uan.isNotEmpty ||
                                company.ptCode.isNotEmpty) &&
                            (company.estCode.isNotEmpty ||
                                company.pfCode.isNotEmpty))
                          tablet ? AppSpaces.v12 : AppSpaces.v10,
                        if (company.estCode.isNotEmpty ||
                            company.pfCode.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (company.estCode.isNotEmpty)
                                Expanded(
                                  child: _buildInfoRow(
                                    label: 'EST Code',
                                    value: company.estCode,
                                    tablet: tablet,
                                  ),
                                ),
                              if (company.estCode.isNotEmpty &&
                                  company.pfCode.isNotEmpty)
                                tablet ? AppSpaces.h16 : AppSpaces.h12,
                              if (company.pfCode.isNotEmpty)
                                Expanded(
                                  child: _buildInfoRow(
                                    label: 'PF Code',
                                    value: company.pfCode,
                                    tablet: tablet,
                                  ),
                                ),
                            ],
                          ),
                        if (company.esiCode.isNotEmpty) ...[
                          tablet ? AppSpaces.v12 : AppSpaces.v10,
                          _buildInfoRow(
                            label: 'ESI Code',
                            value: company.esiCode,
                            tablet: tablet,
                          ),
                        ],
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                      ],

                      // Bank Details
                      if (company.coBankName1.isNotEmpty ||
                          company.coBankName2.isNotEmpty) ...[
                        Divider(
                          height: 1,
                          color: kColorLightGrey.withOpacity(0.5),
                        ),
                        tablet ? AppSpaces.v12 : AppSpaces.v10,
                        _buildSectionHeader('Bank Details', tablet),

                        if (company.coBankName1.isNotEmpty) ...[
                          _buildInfoRow(
                            label: 'Bank 1 - Name',
                            value: company.coBankName1,
                            tablet: tablet,
                          ),
                          tablet ? AppSpaces.v8 : AppSpaces.v6,
                          if (company.coBankBranch1.isNotEmpty ||
                              company.coBankAcNo1.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (company.coBankBranch1.isNotEmpty)
                                  Expanded(
                                    child: _buildInfoRow(
                                      label: 'Branch',
                                      value: company.coBankBranch1,
                                      tablet: tablet,
                                    ),
                                  ),
                                if (company.coBankBranch1.isNotEmpty &&
                                    company.coBankAcNo1.isNotEmpty)
                                  tablet ? AppSpaces.h16 : AppSpaces.h12,
                                if (company.coBankAcNo1.isNotEmpty)
                                  Expanded(
                                    child: _buildInfoRow(
                                      label: 'Account No',
                                      value: company.coBankAcNo1,
                                      tablet: tablet,
                                    ),
                                  ),
                              ],
                            ),
                          if (company.coBankIfsc1.isNotEmpty) ...[
                            tablet ? AppSpaces.v8 : AppSpaces.v6,
                            _buildInfoRow(
                              label: 'IFSC Code',
                              value: company.coBankIfsc1,
                              tablet: tablet,
                            ),
                          ],
                          tablet ? AppSpaces.v12 : AppSpaces.v10,
                        ],

                        if (company.coBankName2.isNotEmpty) ...[
                          _buildInfoRow(
                            label: 'Bank 2 - Name',
                            value: company.coBankName2,
                            tablet: tablet,
                          ),
                          tablet ? AppSpaces.v8 : AppSpaces.v6,
                          if (company.coBankBranch2.isNotEmpty ||
                              company.coBankAcNo2.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (company.coBankBranch2.isNotEmpty)
                                  Expanded(
                                    child: _buildInfoRow(
                                      label: 'Branch',
                                      value: company.coBankBranch2,
                                      tablet: tablet,
                                    ),
                                  ),
                                if (company.coBankBranch2.isNotEmpty &&
                                    company.coBankAcNo2.isNotEmpty)
                                  tablet ? AppSpaces.h16 : AppSpaces.h12,
                                if (company.coBankAcNo2.isNotEmpty)
                                  Expanded(
                                    child: _buildInfoRow(
                                      label: 'Account No',
                                      value: company.coBankAcNo2,
                                      tablet: tablet,
                                    ),
                                  ),
                              ],
                            ),
                          if (company.coBankIfsc2.isNotEmpty) ...[
                            tablet ? AppSpaces.v8 : AppSpaces.v6,
                            _buildInfoRow(
                              label: 'IFSC Code',
                              value: company.coBankIfsc2,
                              tablet: tablet,
                            ),
                          ],
                        ],
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
                        'Delete Company',
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
                      'Are you sure you want to delete "${company.name}"?',
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
                            onPressed: () => Get.back(),
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
