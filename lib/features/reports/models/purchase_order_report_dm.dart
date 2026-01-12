import 'package:flutter/material.dart';

class PurchaseOrderReportDm {
  final String poNo;
  final String poDate;
  final String iCode;
  final String iName;
  final String unit;
  final double poQty;
  final double rate;
  final double amount;
  final String siteCode;
  final String siteName;
  final String pCode;
  final String partyName;
  final bool authorize;
  final String poStatus;

  PurchaseOrderReportDm({
    required this.poNo,
    required this.poDate,
    required this.iCode,
    required this.iName,
    required this.unit,
    required this.poQty,
    required this.rate,
    required this.amount,
    required this.siteCode,
    required this.siteName,
    required this.pCode,
    required this.partyName,
    required this.authorize,
    required this.poStatus,
  });

  factory PurchaseOrderReportDm.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderReportDm(
      poNo: json['PONo'] ?? '',
      poDate: json['PODate'] ?? '',
      iCode: json['ICode'] ?? '',
      iName: json['IName'] ?? '',
      unit: json['Unit'] ?? '',
      poQty: (json['POQty'] ?? 0).toDouble(),
      rate: (json['Rate'] ?? 0).toDouble(),
      amount: (json['Amount'] ?? 0).toDouble(),
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      pCode: json['PCode'] ?? '',
      partyName: json['PartyName'] ?? '',
      authorize: json['Authorize'] ?? false,
      poStatus: json['POStatus'] ?? '',
    );
  }

  Color get statusColor {
    switch (poStatus.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'complete':
        return Colors.green;
      case 'close':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (poStatus.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'complete':
        return 'Complete';
      case 'close':
        return 'Closed';
      default:
        return poStatus;
    }
  }
}
