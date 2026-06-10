class IssueReportDm {
  final String invno;
  final String issueDate;
  final String iName;
  final double qty;
  final double totalIssueQty;
  final String pName;
  final String grnDate;
  final String gdName;

  IssueReportDm({
    required this.invno,
    required this.issueDate,
    required this.iName,
    required this.qty,
    required this.totalIssueQty,
    required this.pName,
    required this.grnDate,
    required this.gdName,
  });

  factory IssueReportDm.fromJson(Map<String, dynamic> json) {
    return IssueReportDm(
      invno: json['Invno'] ?? '',
      issueDate: json['IssueDate'] ?? '',
      iName: json['IName'] ?? '',
      qty: (json['Qty'] ?? 0).toDouble(),
      totalIssueQty: (json['TotalIssueQty'] ?? 0).toDouble(),
      pName: json['PName'] ?? '',
      grnDate: json['GrnDate'] ?? '',
      gdName: json['GDName'] ?? '',
    );
  }
}
