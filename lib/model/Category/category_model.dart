class CategoryModel {
  final int id;
  final String name;
  final String emoji;

  CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      emoji: json['category_emoji'],
    );
  }

  String get displayName => '$emoji $name';
  @override
  String toString() {
    return '$emoji $name';
  }
}
