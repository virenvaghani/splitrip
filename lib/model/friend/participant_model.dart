import '../trip/trip_model.dart';
import 'linkuser_model.dart';

class ParticipantModel {
  final int? id;
  final String? name; // General participant list name
  final double? member;
  final String? referenceId;
  final String? user;
  final List<LinkedUserModel> linkedUsers;

  // Fields from selected_participants (TripMembership-style)
  final String? participantReferenceId;
  final String? participantName;
  final double? participantMember;
  double? customMemberCount;
  final List<Trip>? participatedTrips;
  final bool isLinked;

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
    this.isLinked = false,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['participnt_id'],
      name: json['name'],
        member: json['member'] == null
            ? null
            : (json['member'] is num)
            ? (json['member'] as num).toDouble()
            : double.tryParse(json['member'].toString()),
         // Convert to double
      referenceId: json['reference_id'],
      user: json['user'],
      linkedUsers: (json['linked_users'] as List<dynamic>?)
          ?.map((e) => LinkedUserModel.fromJson(e))
          .toList() ??
          [],
      participantReferenceId: json['participant_reference_id'],
      participantName: json['participant_name'],
      participantMember: (json['participant_member'] as num?)?.toDouble(), // Convert to double
      customMemberCount: (json['custom_member_count'] as num?)?.toDouble(),
      participatedTrips: (json['participated_trips'] as List<dynamic>?)
          ?.map((trip) => Trip.fromJson(trip))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participnt_id': id,
      'name': name,
      'member': member,
      'reference_id': referenceId,
      'user': user,
      'linked_users': linkedUsers.map((e) => e.toJson()).toList(),
      'participant_reference_id': participantReferenceId,
      'participant_name': participantName,
      'participant_member': participantMember,
      'custom_member_count': customMemberCount,
      'participated_trips': participatedTrips?.map((trip) => trip.toJson()).toList(),
    };
  }

  /// Getter for display name fallback logic
  String get displayName => participantName ?? name ?? "Unknown";

  /// Getter for reference ID fallback logic
  String get displayReferenceId =>
      participantReferenceId ?? referenceId ?? "";

  /// Getter for member count fallback logic
  double get displayMemberCount =>
      customMemberCount?.toDouble() ?? participantMember ?? member ?? 1.0;
}