class ParticipantModel {
  final int? id;
  final String? name;
  final int member;
  final String? referenceId;
  final String? user; // now a string

  ParticipantModel({
    this.id,
    required this.name,
    required this.member,
    this.referenceId,
    this.user,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'],
      name: json['name'],
      member: json['member'],
      referenceId: json['reference_id'],
      user: json['user'], // string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'member': member,
      'reference_id': referenceId,
      'user': user,
    };
  }
}
