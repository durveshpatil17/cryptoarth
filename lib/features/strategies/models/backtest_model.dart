class BacktestModel {
  final String? id;
  final String strategyCode;
  final String status;
  final num pnl;
  final num winRate;
  final num drawdown;
  final int totalTrades;
  final String? createdAt;
  final String? userName;
  final String? ownerId;
  final bool isOwner;
  final String strategyName;

  BacktestModel({
    this.id,
    required this.strategyCode,
    required this.status,
    required this.pnl,
    required this.winRate,
    required this.drawdown,
    this.totalTrades = 0,
    this.createdAt,
    this.userName,
    this.ownerId,
    this.isOwner = false,
    required this.strategyName,
  });

  factory BacktestModel.fromJson(Map<String, dynamic> json) {
    return BacktestModel(
      id: json['id']?.toString(),
      strategyCode: json['strategy_code']?.toString() ?? json['id']?.toString() ?? 'AI_Generated',
      status: json['status']?.toString() ?? 'Success',
      pnl: num.tryParse(json['pnl']?.toString() ?? json['total_pnl']?.toString() ?? '0') ?? 0,
      winRate: num.tryParse(json['win_rate']?.toString() ?? json['winrate']?.toString() ?? '0') ?? 0,
      drawdown: num.tryParse(json['drawdown']?.toString() ?? json['max_drawdown_percent']?.toString() ?? '0') ?? 0,
      totalTrades: int.tryParse(json['total_trades']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString(),
      userName: json['user_name']?.toString() ?? json['username']?.toString() ?? json['owner_name']?.toString(),
      ownerId: json['owner_id']?.toString() ?? json['user_id']?.toString(),
      isOwner: json['is_owner'] == true || json['is_owner'] == 1 || json['is_owner'] == '1',
      strategyName: json['strategy_name']?.toString() ?? json['strategy_code']?.toString() ?? 'AI Strategy',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'strategy_code': strategyCode,
      'status': status,
      'pnl': pnl,
      'win_rate': winRate,
      'strategy_name': strategyName,
      'drawdown': drawdown,
      'total_trades': totalTrades,
    };
  }
}
