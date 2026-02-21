class UserModel {
  final int id;
  final String? phone;
  final String? email;
  final String? name;
  final int? credits;

  UserModel({
    required this.id,
    this.phone,
    this.email,
    this.name,
    this.credits,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id']?.toString() ?? json['user_id']?.toString() ?? '') ?? 0,
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      name: json['name']?.toString() ?? json['first_name']?.toString(),
      credits: int.tryParse(json['credits']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'name': name,
      'credits': credits,
    };
  }
}
