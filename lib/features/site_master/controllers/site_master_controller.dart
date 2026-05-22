import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/company_master/models/company_master_dm.dart';
import 'package:shivay_construction/features/party_masters/models/city_dm.dart';
import 'package:shivay_construction/features/party_masters/models/state_dm.dart';
import 'package:shivay_construction/features/site_master/controllers/site_master_list_controller.dart';
import 'package:shivay_construction/features/site_master/models/site_master_dm.dart';
import 'package:shivay_construction/features/site_master/repos/site_master_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class SiteMasterController extends GetxController {
  var isLoading = false.obs;
  final siteFormKey = GlobalKey<FormState>();

  var siteNameController = TextEditingController();
  var address1Controller = TextEditingController();
  var address2Controller = TextEditingController();
  var pinCodeController = TextEditingController();
  var phoneController = TextEditingController();
  var faxController = TextEditingController();
  var emailController = TextEditingController();
  var panController = TextEditingController();
  var gstNumberController = TextEditingController();

  // City dropdown
  var cityList = <CityDm>[].obs;
  var cityNames = <String>[].obs;
  var selectedCity = ''.obs;

  // State dropdown
  var stateList = <StateDm>[].obs;
  var stateNames = <String>[].obs;
  var selectedState = ''.obs;

  // Company dropdown — populated from /Master/getCompany
  var companyList = <CompanyMasterDm>[].obs;
  var companyNames = <String>[].obs;
  var selectedCompanyName = ''.obs;
  var selectedCompanyCode = ''.obs;

  // Edit mode
  var isEditMode = false.obs;
  var currentSiteCode = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    await fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    isLoading.value = true;
    await getCities();
    await getStates();
    await getCompanies();
    isLoading.value = false;
  }

  // ── City ──────────────────────────────────────────────────────────────────

  Future<void> getCities() async {
    try {
      final data = await SiteMasterRepo.getCities();
      cityList.assignAll(data);
      cityNames.assignAll(data.map((e) => e.value));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void onCitySelected(String? city) {
    selectedCity.value = city ?? '';
  }

  void addNewCity(String value) {
    final newCity = CityDm(value: value);
    cityList.add(newCity);
    cityNames.add(value);
    selectedCity.value = value;
  }

  // ── State ─────────────────────────────────────────────────────────────────

  Future<void> getStates() async {
    try {
      final data = await SiteMasterRepo.getStates();
      stateList.assignAll(data);
      stateNames.assignAll(data.map((e) => e.value));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  void onStateSelected(String? state) {
    selectedState.value = state ?? '';
  }

  void addNewState(String value) {
    final newState = StateDm(value: value);
    stateList.add(newState);
    stateNames.add(value);
    selectedState.value = value;
  }

  // ── Company ───────────────────────────────────────────────────────────────

  Future<void> getCompanies() async {
    try {
      final data = await SiteMasterRepo.getCompanies();
      companyList.assignAll(data);
      // Display names shown in dropdown
      companyNames.assignAll(data.map((e) => e.name));
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    }
  }

  /// Called when user picks a company from the dropdown.
  /// Stores both the display name and the CoCode string for the API.
  void onCompanySelected(String? name) {
    if (name == null || name.isEmpty) {
      selectedCompanyName.value = '';
      selectedCompanyCode.value = '';
      return;
    }
    selectedCompanyName.value = name;
    final match = companyList.firstWhereOrNull((c) => c.name == name);
    selectedCompanyCode.value = match != null ? match.coCode.toString() : '';
  }

  // ── Edit mode ─────────────────────────────────────────────────────────────

  void autoFillDataForEdit(SiteMasterDm site) {
    isEditMode.value = true;
    currentSiteCode.value = site.siteCode;

    siteNameController.text = site.siteName;
    address1Controller.text = site.address1;
    address2Controller.text = site.address2;
    pinCodeController.text = site.pinCode;
    phoneController.text = site.phone;
    faxController.text = site.fax;
    emailController.text = site.email;
    panController.text = site.pan;
    gstNumberController.text = site.gstNumber;

    if (site.city.isNotEmpty) selectedCity.value = site.city;
    if (site.state.isNotEmpty) selectedState.value = site.state;

    // Restore company selection from the stored company code
    if (site.company.isNotEmpty) {
      final match = companyList.firstWhereOrNull(
        (c) => c.coCode.toString() == site.company,
      );
      if (match != null) {
        selectedCompanyName.value = match.name;
        selectedCompanyCode.value = match.coCode.toString();
      } else {
        // Fallback: use CompanyName text if code lookup fails
        selectedCompanyName.value = site.companyName;
        selectedCompanyCode.value = site.company;
      }
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> addUpdateSiteMaster() async {
    isLoading.value = true;
    try {
      final response = await SiteMasterRepo.addUpdateSiteMaster(
        siteCode: currentSiteCode.value,
        siteName: siteNameController.text.trim(),
        address1: address1Controller.text.trim(),
        address2: address2Controller.text.trim(),
        city: selectedCity.value,
        state: selectedState.value,
        pinCode: pinCodeController.text.trim(),
        phone: phoneController.text.trim(),
        fax: faxController.text.trim(),
        email: emailController.text.trim(),
        pan: panController.text.trim(),
        gstNumber: gstNumberController.text.trim(),
        company: selectedCompanyCode.value,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        Get.back();
        showSuccessSnackbar('Success', message);

        if (Get.isRegistered<SiteMasterListController>()) {
          final listController = Get.find<SiteMasterListController>();
          await listController.getSites();
          listController.filterSites(listController.searchController.text);
        }

        clearAll();
      }
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

  // ── Clear ─────────────────────────────────────────────────────────────────

  void clearAll() {
    siteNameController.clear();
    address1Controller.clear();
    address2Controller.clear();
    pinCodeController.clear();
    phoneController.clear();
    faxController.clear();
    emailController.clear();
    panController.clear();
    gstNumberController.clear();

    selectedCity.value = '';
    selectedState.value = '';
    selectedCompanyName.value = '';
    selectedCompanyCode.value = '';

    isEditMode.value = false;
    currentSiteCode.value = '';
  }
}
