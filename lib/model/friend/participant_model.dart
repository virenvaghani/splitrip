import '../trip/trip_model.dart';
import 'linkuser_model.dart';

class ParticipantModel {
  final int? id;
  final String? name; // General participant list name
  final int? member;
  final String? referenceId;
  final String? user;
  final List<LinkedUserModel> linkedUsers;

  // Fields from selected_participants (TripMembership-style)
  final String? participantReferenceId;
  final String? participantName;
  final int? participantMember;
  int? customMemberCount;
  final List<Trip>? participatedTrips;

  ParticipantModel({
    this.id,
    this.name,
    this.member,
    this.referenceId,
    this.user,
    required this.linkedUsers,
    this.customMemberCount,
    this.participantReferenceId,
    this.participantName,
    this.participantMember,
    this.participatedTrips,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'],
      name: json['name'],
      member: json['member'],
      referenceId: json['reference_id'],
      user: json['user'],
      linkedUsers: (json['linked_users'] as List<dynamic>?)
          ?.map((e) => LinkedUserModel.fromJson(e))
          .toList() ??
          [],
      participantReferenceId: json['participant_reference_id'],
      participantName: json['participant_name'],
      participantMember: json['participant_member'],
      customMemberCount: json['custom_member_count'],
      participatedTrips: (json['participated_trips'] as List<dynamic>?)
          ?.map((trip) => Trip.fromJson(trip))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'member': member,
      'reference_id': referenceId,
      'user': user,
      'linked_users': linkedUsers.map((e) => e.toJson()).toList(),
      'participant_reference_id': participantReferenceId,
      'participant_name': participantName,
      'participant_member': participantMember,
      'custom_member_count': customMemberCount,
      'participatedTrips':participatedTrips,
    };
  }

  /// Getter for display name fallback logic
  String get displayName => participantName ?? name ?? "Unknown";

  /// Getter for reference ID fallback logic
  String get displayReferenceId =>
      participantReferenceId ?? referenceId ?? "";

  /// Getter for member count fallback logic
  int get displayMemberCount =>
      customMemberCount ?? participantMember ?? member ?? 1;
}
