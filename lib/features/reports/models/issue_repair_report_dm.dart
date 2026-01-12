import 'package:flutter/material.dart';

class IssueRepairReportDm {
  final String issueInvNo;
  final String issueDate;
  final String pCode;
  final String pName;
  final String siteCode;
  final String siteName;
  final String gdCode;
  final String gdName;
  final String description;
  final String remarks;
  final double issuedQty;
  final double receivedQty;
  final double pendingQty;
  final String status;

  IssueRepairReportDm({
    required this.issueInvNo,
    required this.issueDate,
    required this.pCode,
    required this.pName,
    required this.siteCode,
    required this.siteName,
    required this.gdCode,
    required this.gdName,
    required this.description,
    required this.remarks,
    required this.issuedQty,
    required this.receivedQty,
    required this.pendingQty,
    required this.status,
  });

  factory IssueRepairReportDm.fromJson(Map<String, dynamic> json) {
    return IssueRepairReportDm(
      issueInvNo: json['IssueInvNo'] ?? '',
      issueDate: json['IssueDate'] ?? '',
      pCode: json['PCode'] ?? '',
      pName: json['PName'] ?? '',
      siteCode: json['SiteCode'] ?? '',
      siteName: json['SiteName'] ?? '',
      gdCode: json['GDCode'] ?? '',
      gdName: json['GDName'] ?? '',
      description: json['Description'] ?? '',
      remarks: json['Remarks'] ?? '',
      issuedQty: (json['IssuedQty'] ?? 0).toDouble(),
      receivedQty: (json['ReceivedQty'] ?? 0).toDouble(),
      pendingQty: (json['PendingQty'] ?? 0).toDouble(),
      status: json['Status'] ?? '',
    );
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'received':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'received':
        return 'Received';
      default:
        return status;
    }
  }
}
