class ItemGroupMasterDm {
  final String igCode;
  final String igName;

  ItemGroupMasterDm({required this.igCode, required this.igName});

  factory ItemGroupMasterDm.fromJson(Map<String, dynamic> json) {
    return ItemGroupMasterDm(
      igCode: json['IGCode'] ?? '',
      igName: json['IGName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'IGCode': igCode, 'IGName': igName};
  }
}
