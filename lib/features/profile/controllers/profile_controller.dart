import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/constants/color_constants.dart';
import 'package:shivay_construction/features/auth/models/year_dm.dart';
import 'package:shivay_construction/features/auth/repos/select_company_repo.dart';
import 'package:shivay_construction/features/auth/screens/login_screen.dart';
import 'package:shivay_construction/features/company_master/models/company_master_dm.dart';
import 'package:shivay_construction/features/company_master/repos/company_master_list_repo.dart';
import 'package:shivay_construction/features/home/screens/home_screen.dart';
import 'package:shivay_construction/styles/font_sizes.dart';
import 'package:shivay_construction/styles/text_styles.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';
import 'package:shivay_construction/utils/helpers/secure_storage_helper.dart';
import 'package:shivay_construction/utils/helpers/version_helper.dart';
import 'package:shivay_construction/utils/screen_utils/app_paddings.dart';
import 'package:shivay_construction/utils/screen_utils/app_screen_utils.dart';
import 'package:shivay_construction/utils/screen_utils/app_spacings.dart';
import 'package:shivay_construction/widgets/app_button.dart';
import 'package:shivay_construction/widgets/app_dropdown.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var fullName = ''.obs;
  var userType = ''.obs;
  var mobileNumber = ''.obs;
  var gdName = ''.obs;
  var appVersion = ''.obs;

  var companies = <CompanyMasterDm>[].obs;
  var companyNames = <String>[].obs;
  var selectedCompanyName = ''.obs;
  var selectedCompanyCode = 0.obs;

  var years = <YearDm>[].obs;
  var finYears = <String>[].obs;
  var selectedFinYear = ''.obs;
  var selectedYearId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserInfo();
    loadAppVersion();
  }

  Future<void> loadUserInfo() async {
    try {
      fullName.value = await SecureStorageHelper.read('fullName') ?? 'Unknown';
      userType.value = await SecureStorageHelper.read('userType') ?? 'guest';
      mobileNumber.value = await SecureStorageHelper.read('mobileNo') ?? '';
      gdName.value = await SecureStorageHelper.read('company') ?? '';
    } catch (e) {
      showErrorSnackbar(
        'Failed to Load User Info',
        'There was an issue loading your profile data. Please try again.',
      );
    }
  }

  Future<void> loadAppVersion() async {
    try {
      appVersion.value = await VersionHelper.getVersion();
    } catch (e) {
      appVersion.value = 'N/A';
    }
  }

  // Future<void> redirectToPlayStore() async {
  //   const playStoreUrl =
  //       'https://play.google.com/store/apps/details?id=com.jinee.pro_manage';

  //   final uri = Uri.parse(playStoreUrl);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   } else {
  //     showErrorSnackbar('Error', 'Could not launch the Play Store.');
  //   }
  // }

  Future<void> logoutUser() async {
    isLoading.value = true;
    try {
      await SecureStorageHelper.clearAll();

      Get.offAll(() => LoginScreen());
    } catch (e) {
      showErrorSnackbar(
        'Logout Failed',
        'Something went wrong. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCompanies() async {
    isLoading.value = true;
    try {
      final data = await CompanyMasterListRepo.getCompanies();
      companies.assignAll(data);
      companyNames.assignAll(data.map((e) => e.name).toList());

      // Auto-select if only one company
      if (data.length == 1) {
        selectedCompanyName.value = data.first.name;
        selectedCompanyCode.value = data.first.coCode;
        await fetchYears(data.first.coCode);
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchYears(int coCode) async {
    isLoading.value = true;
    try {
      final data = await SelectCompanyRepo.getYears(coCode: coCode);
      years.assignAll(data);
      finYears.assignAll(data.map((e) => e.finYear).toList());

      if (data.isNotEmpty) {
        selectedFinYear.value = data.first.finYear;
        selectedYearId.value = data.first.yearId;
      }
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onCompanySelected(String? name) {
    if (name == null || name.isEmpty) return;
    selectedCompanyName.value = name;
    final match = companies.firstWhereOrNull((c) => c.name == name);
    if (match != null) {
      selectedCompanyCode.value = match.coCode;
      fetchYears(match.coCode);
    }
  }

  void onYearSelected(String? finYear) {
    if (finYear == null) return;
    selectedFinYear.value = finYear;
    final match = years.firstWhereOrNull((y) => y.finYear == finYear);
    if (match != null) selectedYearId.value = match.yearId;
  }

  Future<void> changeCompany(BuildContext context) async {
    // Reset selections before opening
    selectedCompanyName.value = '';
    selectedCompanyCode.value = 0;
    years.clear();
    finYears.clear();
    selectedFinYear.value = '';
    selectedYearId.value = 0;

    await fetchCompanies();
    _showChangeCompanyDialog(context);
  }

  void _showChangeCompanyDialog(BuildContext context) {
    final bool tablet = AppScreenUtils.isTablet(context);
    final dialogFormKey = GlobalKey<FormState>();

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
                color: kColorPrimary.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: tablet
                    ? AppPaddings.combined(horizontal: 24, vertical: 20)
                    : AppPaddings.combined(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: kColorPrimary.withOpacity(0.08),
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
                        color: kColorPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(tablet ? 12 : 10),
                      ),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        color: kColorPrimary,
                        size: tablet ? 26 : 22,
                      ),
                    ),
                    tablet ? AppSpaces.h12 : AppSpaces.h10,
                    Expanded(
                      child: Text(
                        'Change Company',
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
              // Body
              Padding(
                padding: tablet ? AppPaddings.p24 : AppPaddings.p20,
                child: Form(
                  key: dialogFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Dropdown
                      Obx(
                        () => AppDropdown(
                          hintText: 'Select Company *',
                          items: companyNames,
                          selectedItem: selectedCompanyName.value.isNotEmpty
                              ? selectedCompanyName.value
                              : null,
                          onChanged: onCompanySelected,
                          validatorText: 'Please select a company',
                        ),
                      ),
                      tablet ? AppSpaces.v16 : AppSpaces.v12,
                      // Year Dropdown
                      Obx(
                        () => AppDropdown(
                          hintText: 'Financial Year *',
                          items: finYears,
                          selectedItem: selectedFinYear.value.isNotEmpty
                              ? selectedFinYear.value
                              : null,
                          onChanged: onYearSelected,
                          validatorText: 'Please select a financial year',
                        ),
                      ),
                      tablet ? AppSpaces.v24 : AppSpaces.v20,
                      // Buttons
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
                              title: 'Continue',
                              buttonColor: kColorPrimary,
                              titleColor: kColorWhite,
                              titleSize: tablet
                                  ? FontSizes.k16FontSize
                                  : FontSizes.k14FontSize,
                              buttonHeight: tablet ? 54 : 48,
                              onPressed: () {
                                if (dialogFormKey.currentState!.validate()) {
                                  Get.back();
                                  _changeCompanyGetToken();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeCompanyGetToken() async {
    isLoading.value = true;
    try {
      final mobile = await SecureStorageHelper.read('mobileNo') ?? '';

      final response = await SelectCompanyRepo.getToken(
        mobileNumber: mobile,
        cid: selectedCompanyCode.value, // coCode == cid as per your note
        yearId: selectedYearId.value,
      );

      // Overwrite secure storage same as SelectCompanyController
      await SecureStorageHelper.write('token', response['token']);
      await SecureStorageHelper.write('fullName', response['fullName']);
      await SecureStorageHelper.write(
        'indentAuth',
        response['indentAuth'].toString(),
      );
      await SecureStorageHelper.write('coCodes', response['coCodes'] ?? '');
      await SecureStorageHelper.write('poAuth', response['poAuth'].toString());
      await SecureStorageHelper.write(
        'userType',
        response['userType'].toString(),
      );
      await SecureStorageHelper.write(
        'mobileNo',
        response['mobileNo'].toString(),
      );
      await SecureStorageHelper.write('userId', response['userId'].toString());
      await SecureStorageHelper.write(
        'ledgerStart',
        response['ledgerStart'] ?? '',
      );
      await SecureStorageHelper.write('ledgerEnd', response['ledgerEnd'] ?? '');
      await SecureStorageHelper.write('eCodes', response['ecodEs'] ?? '');
      await SecureStorageHelper.write('pCodes', response['pcodEs'] ?? '');
      await SecureStorageHelper.write('seCodes', response['secodEs'] ?? '');
      await SecureStorageHelper.write('company', selectedCompanyName.value);
      await SecureStorageHelper.write(
        'coCode',
        selectedCompanyCode.value.toString(),
      );

      // Reload profile info
      await loadUserInfo();

      showSuccessSnackbar('Success', 'Company changed successfully');
      Get.offAll(() => HomeScreen());
    } catch (e) {
      if (e is Map<String, dynamic>) {
        showErrorSnackbar('Error', e['message']);
      } else {
        showErrorSnackbar('Error', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }
}
