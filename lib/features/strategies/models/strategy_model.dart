class StrategyModel {
  final String id;
  final String strategyName;
  final String strategyCode;
  final String createdAt;
  final bool isDeployed;
  final int brokerId;
  final num winRate;
  final num totalPnl;
  final num maxDrawdown;
  final bool isActive;

  StrategyModel({
    required this.id,
    required this.strategyName,
    required this.strategyCode,
    required this.createdAt,
    required this.isDeployed,
    required this.brokerId,
    this.winRate = 0.0,
    this.totalPnl = 0.0,
    this.maxDrawdown = 0.0,
    this.isActive = false,
  });

  factory StrategyModel.fromJson(Map<String, dynamic> json) {
    return StrategyModel(
      id: json['id']?.toString() ?? '',
      strategyName: json['strategy_name']?.toString() ?? 'Unknown Strategy',
      strategyCode: json['strategy_code']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      isDeployed: json['is_deployed'] == true || json['is_deployed'] == 'true',
      brokerId: int.tryParse(json['broker_id']?.toString() ?? '') ?? 0,
      winRate: num.tryParse(json['win_rate']?.toString() ?? '') ?? 0.0,
      totalPnl: num.tryParse(json['total_pnl']?.toString() ?? '') ?? 0.0,
      maxDrawdown: num.tryParse(json['max_drawdown']?.toString() ?? '') ?? 0.0,
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == '1' || json['is_active'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'strategy_name': strategyName,
      'strategy_code': strategyCode,
      'created_at': createdAt,
      'is_deployed': isDeployed,
      'broker_id': brokerId,
    };
  }
}
