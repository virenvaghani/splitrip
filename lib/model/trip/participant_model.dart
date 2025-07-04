class ParticipantModel {
  final int? id;
  final String? name;
  final int? member; // Changed to nullable to handle null in response
  final String? referenceId;
  final String? user;
  final List<String>? linkedUsers;

  ParticipantModel({
    this.id,
    required this.name,
    this.member,
    this.referenceId,
    this.user,
    this.linkedUsers,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'],
      name: json['name'] as String?,
      member: json['member'] as int?, // Allow null for member
      referenceId: json['reference_id'] as String?,
      user: json['user'],
      linkedUsers: json['linked_users'] != null ? List<String>.from(json['linked_users'] as List) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'member': member,
      'reference_id': referenceId,
      'user': user,
      'linked_users': linkedUsers,
    };
  }
}