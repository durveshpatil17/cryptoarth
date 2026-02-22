class StrategyModel {
  final String id;
  final String? deploymentId;
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
    this.deploymentId,
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
    // For user strategies, 'id' is the deployment ID, and 'backtest_result' contains the strategy info
    // For dashboard strategies, 'id' is the strategy UUID directly
    final String? deploymentId = json.containsKey('backtest_result') ? json['id']?.toString() : null;
    
    final data = (json.containsKey('backtest_result') && json['backtest_result'] is Map) 
                 ? json['backtest_result'] 
                 : json;

    final String strategyId = data['id']?.toString() ?? '';
    final String strategyCode = data['strategy_code']?.toString() ?? '';

    // Check various activity/deployment flags. 
    // dashBoard uses 'is_active' (int or bool) and 'show_in_my_strategies'
    // user strategies use nested 'is_active' in backtest_result
    final bool isActive = json['is_active'] == true || 
                          json['is_active'] == 1 ||
                          json['is_active'] == '1' ||
                          data['is_active'] == true || 
                          data['is_active'] == 1 ||
                          data['is_active'] == '1' ||
                          json['is_deployed'] == true || 
                          json['is_deployed'] == 1;

    return StrategyModel(
      id: strategyId,
      deploymentId: deploymentId,
      strategyName: data['strategy_name']?.toString() ?? 'Unknown Strategy',
      strategyCode: strategyCode,
      createdAt: data['created_at']?.toString() ?? '',
      isDeployed: isActive,
      brokerId: int.tryParse(json['broker_id']?.toString() ?? '') ?? 0,
      winRate: num.tryParse(data['win_rate']?.toString() ?? '') ?? 0.0,
      totalPnl: num.tryParse(data['total_pnl']?.toString() ?? '') ?? 0.0,
      maxDrawdown: num.tryParse(data['max_drawdown']?.toString() ?? '') ?? 0.0,
      isActive: isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deployment_id': deploymentId,
      'strategy_name': strategyName,
      'strategy_code': strategyCode,
      'created_at': createdAt,
      'is_deployed': isDeployed,
      'broker_id': brokerId,
    };
  }
}
