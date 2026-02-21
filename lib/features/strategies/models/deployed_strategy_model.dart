class DeployedStrategyModel {
  final String strategyName;
  final String strategyCode;

  DeployedStrategyModel({
    required this.strategyName,
    required this.strategyCode,
  });

  factory DeployedStrategyModel.fromJson(Map<String, dynamic> json) {
    return DeployedStrategyModel(
      strategyName: json['strategy_name']?.toString() ?? 'Unknown',
      strategyCode: json['strategy_code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strategy_name': strategyName,
      'strategy_code': strategyCode,
    };
  }
}
