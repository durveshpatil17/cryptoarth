class PnLModel {
  final num todayProfit;
  final num totalProfit;
  final int trades;

  PnLModel({
    required this.todayProfit,
    required this.totalProfit,
    required this.trades,
  });

  factory PnLModel.fromJson(Map<String, dynamic> json) {
    return PnLModel(
      todayProfit: num.tryParse(json['today_profit']?.toString() ?? '') ?? 0,
      totalProfit: num.tryParse(json['total_profit']?.toString() ?? '') ?? 0,
      trades: int.tryParse(json['trades']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_profit': todayProfit,
      'total_profit': totalProfit,
      'trades': trades,
    };
  }
}
