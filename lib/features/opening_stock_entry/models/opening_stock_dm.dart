import 'package:shivay_construction/features/opening_stock_entry/models/opening_stock_detail_dm.dart';

class OpeningStockDm {
  final String invNo;
  final String date;
  final String siteCode;
  final String siteName;
  final String gdCode;
  final String gdName;
  final List<OpeningStockDetailDm> items;

  OpeningStockDm({
    required this.invNo,
    required this.date,
    required this.siteCode,
    required this.siteName,
    required this.gdCode,
    required this.gdName,
    required this.items,
  });

  factory OpeningStockDm.fromJson(Map<String, dynamic> json) {
    return OpeningStockDm(
      invNo: json['invNo'] ?? '',
      date: json['date'] ?? '',
      siteCode: json['siteCode'] ?? '',
      siteName: json['siteName'] ?? '',
      gdCode: json['gdCode'] ?? '',
      gdName: json['gdName'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
                .map((item) => OpeningStockDetailDm.fromJson(item))
                .toList()
          : [],
    );
  }
}
