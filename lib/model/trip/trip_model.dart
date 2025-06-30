class Trip {
  final String? id;
  final String tripEmoji;
  final String tripName;
  final String tripCurrency;
  final String? inviteCode;
  final String? createdBy;
  final List<String> participantReferenceIds;
  final int? totalParticipants; // <-- new field

  Trip({
    this.id,
    required this.tripEmoji,
    required this.tripName,
    required this.tripCurrency,
    this.inviteCode,
    this.createdBy,
    required this.participantReferenceIds,
    this.totalParticipants,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    // This method now handles both flat and nested trip objects
    final tripData = json['trip'] ?? json; // if nested under 'trip', unwrap it

    return Trip(
      id: tripData['id']?.toString(),
      tripEmoji: tripData['trip_emoji']?.toString() ?? '🏝️',
      tripName: tripData['trip_name']?.toString() ?? '',
      tripCurrency: tripData['trip_currency']?.toString() ?? 'USD',
      inviteCode: tripData['invite_code']?.toString(),
      createdBy: tripData['created_by']?.toString(),
      participantReferenceIds: tripData['participants'] != null && tripData['participants'] is List
          ? List<String>.from(tripData['participants'].map((p) => p.toString()))
          : [],
      totalParticipants: json['total_participants'], // from wrapper
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'trip_emoji': tripEmoji,
      'trip_name': tripName,
      'trip_currency': tripCurrency,
      'participants': participantReferenceIds,
      // inviteCode, createdBy, and totalParticipants are backend-managed
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
    );
  }
}
