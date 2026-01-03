class ItemSubGroupMasterDm {
  final String icCode;
  final String icName;

  ItemSubGroupMasterDm({required this.icCode, required this.icName});

  factory ItemSubGroupMasterDm.fromJson(Map<String, dynamic> json) {
    return ItemSubGroupMasterDm(
      icCode: json['ICCode'] ?? '',
      icName: json['ICName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'ICCode': icCode, 'ICName': icName};
  }
}
