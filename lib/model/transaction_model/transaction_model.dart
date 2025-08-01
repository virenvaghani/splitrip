import 'dart:convert';

class Transfer {
  final String type;
  final int trip;
  final int currency;
  final double amount;
  final double exchangeRate;
  final int fromParticipant;
  final List<Payee> payees;
  final List<Receiver> receivers;

  Transfer({
    required this.type,
    required this.trip,
    required this.currency,
    required this.amount,
    required this.exchangeRate,
    required this.fromParticipant,
    required this.payees,
    required this.receivers,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      type: json['type'] as String,
      trip: json['trip'] as int,
      currency: json['currency'] as int,
      amount: (json['amount'] as num).toDouble(),
      exchangeRate: (json['exchange_rate'] as num).toDouble(),
      fromParticipant: json['from_participant'] as int,
      payees: (json['payees'] as List<dynamic>)
          .map((e) => Payee.fromJson(e as Map<String, dynamic>))
          .toList(),
      receivers: (json['receivers'] as List<dynamic>)
          .map((e) => Receiver.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'trip': trip,
      'currency': currency,
      'amount': amount,
      'exchange_rate': exchangeRate,
      'from_participant': fromParticipant,
      'payees': payees.map((e) => e.toJson()).toList(),
      'receivers': receivers.map((e) => e.toJson()).toList(),
    };
  }
}

class Payee {
  final int participant;
  final double amount;

  Payee({
    required this.participant,
    required this.amount,
  });

  factory Payee.fromJson(Map<String, dynamic> json) {
    return Payee(
      participant: json['participant'] as int,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participant': participant,
      'amount': amount,
    };
  }
}

class Receiver {
  final int participant;
  final double amount;

  Receiver({
    required this.participant,
    required this.amount,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) {
    return Receiver(
      participant: json['participant'] as int,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participant': participant,
      'amount': amount,
    };
  }
}