import 'package:splitrip/model/trip/participant_model.dart';

class TripModel  {
  int? id;
  String? tripEmoji;
  String? tripName;
  String? currency;
  List<ParticipantModel>? participantModelList;
  TripModel({this.id, this.tripName, this.currency, this.tripEmoji, this.participantModelList});
}