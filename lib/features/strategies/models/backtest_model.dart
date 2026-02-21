class BacktestModel {
  final String strategyCode;
  final String status;
  final num pnl;
  final num winRate;
  final num drawdown;

  BacktestModel({
    required this.strategyCode,
    required this.status,
    required this.pnl,
    required this.winRate,
    required this.drawdown,
  });

  factory BacktestModel.fromJson(Map<String, dynamic> json) {
    return BacktestModel(
      strategyCode: json['strategy_code']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Unknown',
      pnl: num.tryParse(json['pnl']?.toString() ?? '') ?? 0,
      winRate: num.tryParse(json['win_rate']?.toString() ?? '') ?? 0,
      drawdown: num.tryParse(json['drawdown']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strategy_code': strategyCode,
      'status': status,
      'pnl': pnl,
      'win_rate': winRate,
      'drawdown': drawdown,
    };
  }
}
