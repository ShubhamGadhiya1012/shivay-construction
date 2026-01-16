class RepairIssueDetailDm {
  final int srNo;
  final String iCode;
  final String iName;
  final double issuedQty;
  final double receivedQty;
  final double balanceQty;

  RepairIssueDetailDm({
    required this.srNo,
    required this.iCode,
    required this.iName,
    required this.issuedQty,
    required this.receivedQty,
    required this.balanceQty,
  });

  factory RepairIssueDetailDm.fromJson(Map<String, dynamic> json) {
    return RepairIssueDetailDm(
      srNo: json['SrNo'] ?? 0,
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      issuedQty: (json['IssuedQty'] as num?)?.toDouble() ?? 0.0,
      receivedQty: (json['ReceivedQty'] as num?)?.toDouble() ?? 0.0,
      balanceQty: (json['BalanceQty'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
