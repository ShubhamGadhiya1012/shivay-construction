import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shivay_construction/features/department_master/models/department_master_dm.dart';
import 'package:shivay_construction/features/department_master/repos/department_master_repo.dart';
import 'package:shivay_construction/utils/dialogs/app_dialogs.dart';

class DepartmentMasterController extends GetxController {
  var isLoading = false.obs;
  final departmentFormKey = GlobalKey<FormState>();

  var departments = <DepartmentMasterDm>[].obs;
  var filteredDepartments = <DepartmentMasterDm>[].obs;
  var searchController = TextEditingController();
  final dNameController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    await getDepartments();
  }

  Future<void> getDepartments() async {
    isLoading.value = true;
    try {
      final fetchedDepartments = await DepartmentMasterRepo.getDepartments();
      departments.assignAll(fetchedDepartments);
      filteredDepartments.assignAll(fetchedDepartments);
    } catch (e) {
      showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterDepartments(String query) {
    if (query.isEmpty) {
      filteredDepartments.assignAll(departments);
    } else {
      filteredDepartments.assignAll(
        departments.where((department) {
          return department.dName.toLowerCase().contains(query.toLowerCase()) ||
              department.dCode.toLowerCase().contains(query.toLowerCase());
        }).toList(),
      );
    }
  }

  Future<void> addUpdateDepartment({
    required String dCode,
    required String dName,
  }) async {
    isLoading.value = true;
    try {
      final response = await DepartmentMasterRepo.addUpdateDepartment(
        dCode: dCode,
        dName: dName,
      );

      if (response != null && response.containsKey('message')) {
        String message = response['message'];
        await getDepartments();
        filterDepartments(searchController.text);
        showSuccessSnackbar('Success', message);
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
}
