class LinkedUserModel {
  final String id;
  final String name;
  final String email;
  final String image;

  LinkedUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
  });

  factory LinkedUserModel.fromJson(Map<String, dynamic> json) {
    return LinkedUserModel(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
    };
  }
}
