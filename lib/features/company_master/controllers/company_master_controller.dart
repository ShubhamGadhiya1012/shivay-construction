import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/company_master/controllers/company_master_list_controller.dart';
import 'package:shivay_construction/features/company_master/models/company_master_dm.dart';
import 'package:shivay_construction/features/company_master/repos/company_master_repo.dart';
import 'package:shivay_construction/features/party_masters/models/city_dm.dart';
import 'package:shivay_construction/features/party_masters/models/state_dm.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class CompanyMasterController extends GetxController {
  var isLoading = false.obs;
  final companyFormKey = GlobalKey<FormState>();

  // Basic Info
  var nameController = TextEditingController();
  var address1Controller = TextEditingController();
  var address2Controller = TextEditingController();
  var zipController = TextEditingController();
  var phoneController = TextEditingController();
  var faxController = TextEditingController();
  var emailController = TextEditingController();
  var urlController = TextEditingController();
  var panController = TextEditingController();
  var gstNumberController = TextEditingController();
  var cinNoController = TextEditingController();
  var msmeNoController = TextEditingController();
  var mgmtEmailController = TextEditingController();
  var countryController = TextEditingController();

  // Statutory Codes
  var uanController = TextEditingController();
  var ptCodeController = TextEditingController();
  var estCodeController = TextEditingController();
  var pfCodeController = TextEditingController();
  var esiCodeController = TextEditingController();

  // Bank 1
  var coBankName1Controller = TextEditingController();
  var coBankBranch1Controller = TextEditingController();
  var coBankAcNo1Controller = TextEditingController();
  var coBankIfsc1Controller = TextEditingController();

  // Bank 2
  var coBankName2Controller = TextEditingController();
  var coBankBranch2Controller = TextEditingController();
  var coBankAcNo2Controller = TextEditingController();
  var coBankIfsc2Controller = TextEditingController();

  // Dropdowns
  var cityList = <CityDm>[].obs;
  var cityNames = <String>[].obs;
  var selectedCity = ''.obs;

  var stateList = <StateDm>[].obs;
  var stateNames = <String>[].obs;
  var selectedState = ''.obs;

  // Edit mode
  var isEditMode = false.obs;
  var currentCoCode = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    countryController.text = 'India';
    await fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    isLoading.value = true;
    await getCities();
    await getStates();
    isLoading.value = false;
  }

  Future<void> getCities() async {
    try {
      final data = await CompanyMasterRepo.getCities();
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

  Future<void> getStates() async {
    try {
      final data = await CompanyMasterRepo.getStates();
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

  void autoFillDataForEdit(CompanyMasterDm company) {
    isEditMode.value = true;
    currentCoCode.value = company.coCode;

    nameController.text = company.name;
    address1Controller.text = company.address1;
    address2Controller.text = company.address2;
    zipController.text = company.zip;
    phoneController.text = company.phone;
    faxController.text = company.fax;
    emailController.text = company.email;
    urlController.text = company.url;
    panController.text = company.pan;
    gstNumberController.text = company.gstNumber;
    cinNoController.text = company.cinNo;
    msmeNoController.text = company.msmeNo;
    mgmtEmailController.text = company.mgmtEmail;
    countryController.text = company.country.isNotEmpty
        ? company.country
        : 'India';

    uanController.text = company.uan;
    ptCodeController.text = company.ptCode;
    estCodeController.text = company.estCode;
    pfCodeController.text = company.pfCode;
    esiCodeController.text = company.esiCode;

    coBankName1Controller.text = company.coBankName1;
    coBankBranch1Controller.text = company.coBankBranch1;
    coBankAcNo1Controller.text = company.coBankAcNo1;
    coBankIfsc1Controller.text = company.coBankIfsc1;

    coBankName2Controller.text = company.coBankName2;
    coBankBranch2Controller.text = company.coBankBranch2;
    coBankAcNo2Controller.text = company.coBankAcNo2;
    coBankIfsc2Controller.text = company.coBankIfsc2;

    if (company.city.isNotEmpty) selectedCity.value = company.city;
    if (company.state.isNotEmpty) selectedState.value = company.state;
  }

  Future<void> addUpdateCompanyMaster() async {
    isLoading.value = true;
    try {
      final response = await CompanyMasterRepo.addUpdateCompanyMaster(
        coCode: currentCoCode.value,
        name: nameController.text.trim(),
        address1: address1Controller.text.trim(),
        address2: address2Controller.text.trim(),
        city: selectedCity.value,
        zip: zipController.text.trim(),
        state: selectedState.value,
        country: countryController.text.trim(),
        pan: panController.text.trim(),
        phone: phoneController.text.trim(),
        fax: faxController.text.trim(),
        email: emailController.text.trim(),
        url: urlController.text.trim(),
        gstNumber: gstNumberController.text.trim(),
        cinNo: cinNoController.text.trim(),
        msmeNo: msmeNoController.text.trim(),
        uan: uanController.text.trim(),
        ptCode: ptCodeController.text.trim(),
        estCode: estCodeController.text.trim(),
        pfCode: pfCodeController.text.trim(),
        esiCode: esiCodeController.text.trim(),
        mgmtEmail: mgmtEmailController.text.trim(),
        coBankName1: coBankName1Controller.text.trim(),
        coBankBranch1: coBankBranch1Controller.text.trim(),
        coBankAcNo1: coBankAcNo1Controller.text.trim(),
        coBankIfsc1: coBankIfsc1Controller.text.trim(),
        coBankName2: coBankName2Controller.text.trim(),
        coBankBranch2: coBankBranch2Controller.text.trim(),
        coBankAcNo2: coBankAcNo2Controller.text.trim(),
        coBankIfsc2: coBankIfsc2Controller.text.trim(),
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        Get.back();
        showSuccessSnackbar('Success', message);

        if (Get.isRegistered<CompanyMasterListController>()) {
          final listController = Get.find<CompanyMasterListController>();
          await listController.getCompanies();
          listController.filterCompanies(listController.searchController.text);
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

  void clearAll() {
    nameController.clear();
    address1Controller.clear();
    address2Controller.clear();
    zipController.clear();
    phoneController.clear();
    faxController.clear();
    emailController.clear();
    urlController.clear();
    panController.clear();
    gstNumberController.clear();
    cinNoController.clear();
    msmeNoController.clear();
    mgmtEmailController.clear();
    countryController.text = 'India';

    uanController.clear();
    ptCodeController.clear();
    estCodeController.clear();
    pfCodeController.clear();
    esiCodeController.clear();

    coBankName1Controller.clear();
    coBankBranch1Controller.clear();
    coBankAcNo1Controller.clear();
    coBankIfsc1Controller.clear();

    coBankName2Controller.clear();
    coBankBranch2Controller.clear();
    coBankAcNo2Controller.clear();
    coBankIfsc2Controller.clear();

    selectedCity.value = '';
    selectedState.value = '';
    isEditMode.value = false;
    currentCoCode.value = 0;
  }

  @override
  void onClose() {
    nameController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    zipController.dispose();
    phoneController.dispose();
    faxController.dispose();
    emailController.dispose();
    urlController.dispose();
    panController.dispose();
    gstNumberController.dispose();
    cinNoController.dispose();
    msmeNoController.dispose();
    mgmtEmailController.dispose();
    countryController.dispose();
    uanController.dispose();
    ptCodeController.dispose();
    estCodeController.dispose();
    pfCodeController.dispose();
    esiCodeController.dispose();
    coBankName1Controller.dispose();
    coBankBranch1Controller.dispose();
    coBankAcNo1Controller.dispose();
    coBankIfsc1Controller.dispose();
    coBankName2Controller.dispose();
    coBankBranch2Controller.dispose();
    coBankAcNo2Controller.dispose();
    coBankIfsc2Controller.dispose();
    super.onClose();
  }
}
