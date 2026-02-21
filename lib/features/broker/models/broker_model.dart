class BrokerModel {
  final String brokerName;
  final bool isConnected;
  final String? apiKey;
  final String createdAt;

  BrokerModel({
    required this.brokerName,
    required this.isConnected,
    this.apiKey,
    required this.createdAt,
  });

  factory BrokerModel.fromJson(Map<String, dynamic> json) {
    return BrokerModel(
      brokerName: json['broker_name'] ?? 'Unknown',
      isConnected: json['is_connected'] ?? false,
      apiKey: json['api_key'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'broker_name': brokerName,
      'is_connected': isConnected,
      'api_key': apiKey,
      'created_at': createdAt,
    };
  }
}
