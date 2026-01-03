class CategoryMasterDm {
  final String cCode;
  final String cName;

  CategoryMasterDm({required this.cCode, required this.cName});

  factory CategoryMasterDm.fromJson(Map<String, dynamic> json) {
    return CategoryMasterDm(
      cCode: json['CCode'] ?? '',
      cName: json['CName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'CCode': cCode, 'CName': cName};
  }
}