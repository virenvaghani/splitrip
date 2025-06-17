import '../user/user_model.dart';

class ParticipantModel {
  final int? id;
  final String name;
  final int member;
  final String referenceId;
  final UserModel? user; // creator of this participant

  ParticipantModel({
    this.id,
    required this.name,
    required this.member,
    required this.referenceId,
    this.user,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'],
      name: json['name'],
      member: json['member'],
      referenceId: json['reference_id'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'member': member,
      'reference_id': referenceId,
      'user': user?.toJson(),
    };
  }
}
