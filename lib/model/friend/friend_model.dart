import '../trip/participant_model.dart';

class FriendModel {
  final ParticipantModel participant;
  bool isSelected;

  FriendModel({
    required this.participant,
    this.isSelected = false,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      participant: ParticipantModel.fromJson(json),
      isSelected: false,
    );
  }

  Map<String, dynamic> toJson() {
    return participant.toJson();
  }
}
