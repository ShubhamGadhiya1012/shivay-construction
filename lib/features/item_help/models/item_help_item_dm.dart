class ItemHelpItemDm {
  final String iCode;
  final String iName;
  final String unit;
  final String description;
  final String cCode;
  final String categoryName;
  final String igCode;
  final String groupName;
  final String icCode;
  final String subGroupName;

  ItemHelpItemDm({
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.description,
    required this.cCode,
    required this.categoryName,
    required this.igCode,
    required this.groupName,
    required this.icCode,
    required this.subGroupName,
  });

  factory ItemHelpItemDm.fromJson(Map<String, dynamic> json) {
    return ItemHelpItemDm(
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      description: json['Description'] ?? '',
      cCode: json['CCode'] ?? '',
      categoryName: json['CategoryName'] ?? '',
      igCode: json['IGCode'] ?? '',
      groupName: json['GroupName'] ?? '',
      icCode: json['ICCode'] ?? '',
      subGroupName: json['SubGroupName'] ?? '',
    );
  }
}
