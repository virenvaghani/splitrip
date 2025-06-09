class ParticipantModel {
  int? id;
  String? name;
  int? memberCount;
  bool? isCurrentUser = false;

  static int _idCounter = 0;
  ParticipantModel({this.id, this.name, this.memberCount, this.isCurrentUser}){
     id = _idCounter++;
  }
}
