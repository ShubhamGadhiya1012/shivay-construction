class FilteredItemDm {
  final String iCode;
  final String iName;

  FilteredItemDm({required this.iCode, required this.iName});

  factory FilteredItemDm.fromJson(Map<String, dynamic> json) {
    return FilteredItemDm(
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
    );
  }
}
