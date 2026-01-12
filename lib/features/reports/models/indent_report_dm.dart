import 'package:flutter/material.dart';

class IndentReportDm {
  final String invno;
  final String indentDate;
  final String iCode;
  final String iName;
  final String siteCode;
  final String siteName;
  final String gdCode;
  final String gdName;
  final double indentQty;
  final double orderQty;
  final String refPOInvNo;
  final String indentStatus;

  IndentReportDm({
    required this.invno,
    required this.indentDate,
    required this.iCode,
    required this.iName,
    required this.siteCode,
    required this.siteName,
    required this.gdCode,
    required this.gdName,
    required this.indentQty,
    required this.orderQty,
    required this.refPOInvNo,
    required this.indentStatus,
  });

  factory IndentReportDm.fromJson(Map<String, dynamic> json) {
    return IndentReportDm(
      invno: json['Invno'] ?? '',
      indentDate: json['IndentDate'] ?? '',
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      gdCode: json['GDCode'] ?? '',
      gdName: json['GDName'] ?? '',
      indentQty: (json['IndentQty'] ?? 0).toDouble(),
      orderQty: (json['OrderQty'] ?? 0).toDouble(),
      refPOInvNo: json['RefPOInvNo'] ?? '',
      indentStatus: json['IndentStatus'] ?? '',
    );
  }

  Color get statusColor {
    switch (indentStatus.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'complete':
        return Colors.green;
      case 'close':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (indentStatus.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'complete':
        return 'Complete';
      case 'close':
        return 'Closed';
      default:
        return indentStatus;
    }
  }

  double get pendingQty => indentQty - orderQty;
}
