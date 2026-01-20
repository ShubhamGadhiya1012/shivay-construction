class ItemHelpLastGrnDm {
  final String invno;
  final String date;
  final String pCode;
  final String pName;
  final String remarks;
  final String iCode;
  final String iName;
  final String unit;
  final double qty;
  final double rate;
  final double amount;
  final String poInvNo;
  final String type;

  ItemHelpLastGrnDm({
    required this.invno,
    required this.date,
    required this.pCode,
    required this.pName,
    required this.remarks,
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.qty,
    required this.rate,
    required this.amount,
    required this.poInvNo,
    required this.type,
  });

  factory ItemHelpLastGrnDm.fromJson(Map<String, dynamic> json) {
    return ItemHelpLastGrnDm(
      invno: json['Invno'] ?? '',
      date: json['Date'] ?? '',
      pCode: json['PCode'] ?? '',
      pName: json['PName'] ?? '',
      remarks: json['Remarks'] ?? '',
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      qty: json['Qty'] != null
          ? double.tryParse(json['Qty'].toString()) ?? 0.0
          : 0.0,
      rate: json['Rate'] != null
          ? double.tryParse(json['Rate'].toString()) ?? 0.0
          : 0.0,
      amount: json['Amount'] != null
          ? double.tryParse(json['Amount'].toString()) ?? 0.0
          : 0.0,
      poInvNo: json['POInvNo'] ?? '',
      type: json['Type'] ?? '',
    );
  }
}
