class FriendModel {
  int? id;
  String? name;
  int? memberCount;
  bool? isSelected;

  // Static counter for auto-incrementing IDs
  static int _idCounter = 0;

  FriendModel({this.id, this.name, this.memberCount, this.isSelected}) {
    // Assign an auto-incremented ID if none is provided
    id ??= _idCounter++;
  }
}