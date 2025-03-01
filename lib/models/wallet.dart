// models/wallet.dart

class Wallet {
  final int? id;
  final String name;
  final String color;
  final String balance;
  final String currency;
  final String type;
  final String? desiredBalance;
  final String? icon;
  final String? userId;
  final String? imagePath;

  Wallet({
    required this.id,
    required this.name,
    required this.color,
    required this.balance,
    this.currency = 'KZT',
    required this.type,
    this.desiredBalance,
    this.icon,
    this.userId,
    this.imagePath,
  });

  static const OrdinaryType = 1;
  static const TargetType = 2;

  // Создание из JSON (Map<String, dynamic>)
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      color: json['color']?.toString() ?? '0xFF9E9E9E',
      // Серый цвет по умолчанию
      balance: json['balance']?.toString() ?? '0',
      currency: 'KZT',
      // По умолчанию используем KZT
      type: json['type']?.toString() ?? '1',
      desiredBalance: json['desired_balance']?.toString(),
      icon: json['icon']?.toString(),
      userId: json['user_id']?.toString(),
      imagePath: json['image_path']?.toString(),
    );
  }

  // Преобразование в JSON (Map<String, dynamic>)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'balance': balance,
      'type': type,
      'desired_balance': desiredBalance,
      'icon': icon,
      'user_id': userId,
      'image_path': imagePath,
    };
  }

  // Получение баланса как double
  double get balanceAsDouble => double.tryParse(balance) ?? 0.0;

  // Получение типа как int
  int get typeAsInt => int.tryParse(type) ?? 1;

  // Получение целевого баланса как int
  int? get desiredBalanceAsInt =>
      desiredBalance != null ? int.tryParse(desiredBalance!) : null;

  // Создание копии объекта с измененными полями
  Wallet copyWith({
    int? id,
    String? name,
    String? color,
    String? balance,
    String? currency,
    String? type,
    String? desiredBalance,
    String? icon,
    String? userId,
    String? imagePath,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      desiredBalance: desiredBalance ?? this.desiredBalance,
      icon: icon ?? this.icon,
      userId: userId ?? this.userId,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
