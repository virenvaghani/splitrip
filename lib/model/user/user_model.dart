class UserModel {
  final int? id;
  final String username;
  final String email;
  final String? image;
  final String? provider;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    this.image,
    this.provider,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      image: json['image'],
      provider: json['provider'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'image': image,
      'provider': provider,
    };
  }
}
