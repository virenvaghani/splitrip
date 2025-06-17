

class Trip {
  final String? id;
  final String tripEmoji;
  final String tripName;
  final String tripCurrency;
  final String inviteCode;
  final String createdBy; // user id or email depending on backend
  final List<int> participantIds; // IDs of linked participants

  Trip({
    this.id,
    required this.tripEmoji,
    required this.tripName,
    required this.tripCurrency,
    required this.inviteCode,
    required this.createdBy,
    required this.participantIds,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id']?.toString(),
      tripEmoji: json['trip_emoji'] ?? '',
      tripName: json['trip_name'] ?? '',
      tripCurrency: json['trip_currency'] ?? '',
      inviteCode: json['invite_code'] ?? '',
      createdBy: json['created_by'].toString(),
      participantIds: List<int>.from(json['participants']?.map((p) => p.toString()) ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_emoji': tripEmoji,
      'trip_name': tripName,
      'trip_currency': tripCurrency,
      'invite_code': inviteCode,
      'created_by': createdBy,
      'participants': participantIds,
    };
  }
}
