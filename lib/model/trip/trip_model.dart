import 'package:splitrip/model/friend/linkuser_model.dart';

class Trip {
  final String? id;
  final String tripEmoji;
  final String tripName;
  final int defaultCurrency;
  final String? inviteCode;
  final String? createdBy;
  final List<String> participantReferenceIds;
  final int? totalParticipants;
  final bool isArchived;
  final bool isDeleted;
  final List<LinkedUserModel>? linkedUsers;

  Trip({
    this.id,
    required this.tripEmoji,
    required this.tripName,
    required this.defaultCurrency,
    this.inviteCode,
    this.createdBy,
    required this.participantReferenceIds,
    this.totalParticipants,
    this.isArchived = false,
    this.isDeleted = false,
    this.linkedUsers,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    final tripData = json['trip'] ?? json;

    return Trip(
      id: tripData['id'] == null ? tripData['trip_id']?.toString() : tripData['id'].toString(),
      tripEmoji: tripData['trip_emoji']?.toString() ?? '🌍',
      tripName: tripData['trip_name']?.toString() ?? '',
      defaultCurrency: (tripData['default_currency']) ?? 15,
      inviteCode: tripData['invite_code']?.toString(),
      createdBy: tripData['created_by']?.toString(),
      participantReferenceIds: tripData['participants'] != null && tripData['participants'] is List
          ? List<String>.from(tripData['participants'].map((p) => p.toString()))
          : [],
      totalParticipants: tripData['total_participants'],
      isArchived: (tripData['is_archived'] as bool?) ?? false,
      isDeleted: (tripData['is_deleted'] as bool?) ?? false,
      linkedUsers: (tripData['linked_users'] as List<dynamic>?)
          ?.map((user) => LinkedUserModel.fromJson(user))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': id, // Include both for compatibility
      'trip_emoji': tripEmoji,
      'trip_name': tripName,
      'default_currency': defaultCurrency,
      'invite_code': inviteCode,
      'created_by': createdBy,
      'participants': participantReferenceIds,
      'total_participants': totalParticipants,
      'is_archived': isArchived,
      'is_deleted': isDeleted,
      'linked_users': linkedUsers?.map((e) => e.toJson()).toList(),
    };
  }

  Trip copyWith({
    String? id,
    String? tripEmoji,
    String? tripName,
    double? defaultCurrency,
    String? inviteCode,
    String? createdBy,
    List<String>? participantReferenceIds,
    int? totalParticipants,
    bool? isArchived,
    bool? isDeleted,
    List<LinkedUserModel>? linkedUsers,
  }) {
    return Trip(
      id: id ?? this.id,
      tripEmoji: tripEmoji ?? this.tripEmoji,
      tripName: tripName ?? this.tripName,
      defaultCurrency: this.defaultCurrency,
      inviteCode: inviteCode ?? this.inviteCode,
      createdBy: createdBy ?? this.createdBy,
      participantReferenceIds: participantReferenceIds ?? this.participantReferenceIds,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      linkedUsers: linkedUsers ?? this.linkedUsers,
    );
  }
}