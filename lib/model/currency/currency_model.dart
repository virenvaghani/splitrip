class CurrencyModel {
  final int id;
  final String code;
  final String name;
  final String symbol;

  CurrencyModel({
    required this.id,
    required this.code,
    required this.name,
    required this.symbol,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      symbol: json['symbol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'symbol': symbol,
    };
  }
}
