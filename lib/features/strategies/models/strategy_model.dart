class StrategyModel {
  final String id;
  final String strategyName;
  final String strategyCode;
  final String createdAt;
  final bool isDeployed;
  final int brokerId;

  StrategyModel({
    required this.id,
    required this.strategyName,
    required this.strategyCode,
    required this.createdAt,
    required this.isDeployed,
    required this.brokerId,
  });

  factory StrategyModel.fromJson(Map<String, dynamic> json) {
    return StrategyModel(
      id: json['id']?.toString() ?? '',
      strategyName: json['strategy_name']?.toString() ?? 'Unknown Strategy',
      strategyCode: json['strategy_code']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      isDeployed: json['is_deployed'] == true || json['is_deployed'] == 'true',
      brokerId: int.tryParse(json['broker_id']?.toString() ?? '') ?? 0,
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
