class DepartmentMasterDm {
  final String dCode;
  final String dName;

  DepartmentMasterDm({required this.dCode, required this.dName});

  factory DepartmentMasterDm.fromJson(Map<String, dynamic> json) {
    return DepartmentMasterDm(
      dCode: json['DCode'] ?? '',
      dName: json['DName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'DCode': dCode, 'DName': dName};
  }
}
