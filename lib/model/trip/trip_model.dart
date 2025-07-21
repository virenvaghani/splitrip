import 'package:splitrip/model/friend/linkuser_model.dart';

class Trip {
  final String? id;
  final String tripEmoji;
  final String tripName;
  final String tripCurrency;
  final String? inviteCode;
  final String? createdBy;
  final List<String> participantReferenceIds;
  final int? totalParticipants;
  final bool isArchived;
  final bool isDeleted;
  final List<LinkedUserModel>?
  linkedUsers;



  Trip({
    this.id,
    required this.tripEmoji,
    required this.tripName,
    required this.tripCurrency,
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
      id: tripData['id'].toString() ?? tripData['trip_id'].toString(),
      tripEmoji: tripData['trip_emoji']?.toString() ?? '🌍',
      tripName: tripData['trip_name']?.toString() ?? '',
      tripCurrency: tripData['trip_currency']?.toString() ?? 'USD',
      inviteCode: tripData['invite_code']?.toString(),
      createdBy: tripData['created_by']?.toString(),
      participantReferenceIds: tripData['participants'] != null && tripData['participants'] is List
          ? List<String>.from(tripData['participants'].map((p) => p.toString()))
          : [],
      totalParticipants: json['total_participants'],
      isArchived: (tripData['is_archived'] as bool?) ?? false,
      isDeleted: (tripData['is_deleted'] as bool?) ?? false,
      linkedUsers: (json['linked_users'] as List<dynamic>?)
          ?.map((user) => LinkedUserModel.fromJson(user))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'trip_id' ?? 'id': id,
      'trip_emoji': tripEmoji,
      'trip_name': tripName,
      'trip_currency': tripCurrency,
      'participants': participantReferenceIds,
      'is_archived': isArchived,
      'is_deleted': isDeleted,
    };
  }

  Trip copyWith({
    String? id,
    String? tripEmoji,
    String? tripName,
    String? tripCurrency,
    String? inviteCode,
    String? createdBy,
    List<String>? participantReferenceIds,
    int? totalParticipants,
    bool? isArchived,
    bool? isDeleted,

  }) {
    return Trip(
      id: id ?? this.id,
      tripEmoji: tripEmoji ?? this.tripEmoji,
      tripName: tripName ?? this.tripName,
      tripCurrency: tripCurrency ?? this.tripCurrency,
      inviteCode: inviteCode ?? this.inviteCode,
      createdBy: createdBy ?? this.createdBy,
      participantReferenceIds: participantReferenceIds ?? this.participantReferenceIds,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
