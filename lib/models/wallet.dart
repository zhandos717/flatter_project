// models/wallet.dart

class Wallet {
  final int? id;
  final String name;
  final String color;
  final String balance;
  final String currency;
  final int type;
  final String? desiredBalance;
  final String? icon;
  final String? userId;
  final String? imagePath;

  // Дополнительные поля для разных типов кошельков
  final String? creditLimit; // Для кредитного кошелька
  final String? interestRate; // Для кредитного или инвестиционного кошелька
  final String? expiryDate; // Для кредитного кошелька
  final String? investmentType; // Для инвестиционного кошелька

  // Константы типов кошельков
  static const OrdinaryType = 1;
  static const TargetType = 2;
  static const InvestmentType = 3;
  static const CreditType = 4;

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
    this.creditLimit,
    this.interestRate,
    this.expiryDate,
    this.investmentType,
  });

  // Создание из JSON (Map<String, dynamic>)
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      color: json['color']?.toString() ?? '0xFF9E9E9E',
      // Серый цвет по умолчанию
      balance: json['balance']?.toString() ?? '0',
      currency: json['currency']?.toString() ?? 'KZT',
      // По умолчанию используем KZT
      type: json['type'] ?? OrdinaryType,
      desiredBalance: json['desired_balance']?.toString(),
      icon: json['icon']?.toString(),
      userId: json['user_id']?.toString(),
      imagePath: json['image_path']?.toString(),
      creditLimit: json['credit_limit']?.toString(),
      interestRate: json['interest_rate']?.toString(),
      expiryDate: json['expiry_date']?.toString(),
      investmentType: json['investment_type']?.toString(),
    );
  }

  // Преобразование в JSON (Map<String, dynamic>)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'balance': balance,
      'currency': currency,
      'type': type,
      'desired_balance': desiredBalance,
      'icon': icon,
      'user_id': userId,
      'image_path': imagePath,
      'credit_limit': creditLimit,
      'interest_rate': interestRate,
      'expiry_date': expiryDate,
      'investment_type': investmentType,
    };
  }

  // Получение баланса как double
  double get balanceAsDouble => double.tryParse(balance) ?? 0.0;

  // Получение типа как int
  int get typeAsInt => type;

  // Получение целевого баланса как int
  int? get desiredBalanceAsInt =>
      desiredBalance != null ? int.tryParse(desiredBalance!) : null;

  // Получение лимита кредита как double
  double? get creditLimitAsDouble =>
      creditLimit != null ? double.tryParse(creditLimit!) : null;

  // Получение процентной ставки как double
  double? get interestRateAsDouble =>
      interestRate != null ? double.tryParse(interestRate!) : null;

  // Получение типа кошелька как строку для отображения
  String get typeAsString {
    switch (type) {
      case OrdinaryType:
        return "Обычный";
      case TargetType:
        return "Целевой";
      case InvestmentType:
        return "Инвестиционный";
      case CreditType:
        return "Кредитный";
      default:
        return "Неизвестный";
    }
  }

  // Создание копии объекта с измененными полями
  Wallet copyWith({
    int? id,
    String? name,
    String? color,
    String? balance,
    String? currency,
    int? type,
    String? desiredBalance,
    String? icon,
    String? userId,
    String? imagePath,
    String? creditLimit,
    String? interestRate,
    String? expiryDate,
    String? investmentType,
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
      creditLimit: creditLimit ?? this.creditLimit,
      interestRate: interestRate ?? this.interestRate,
      expiryDate: expiryDate ?? this.expiryDate,
      investmentType: investmentType ?? this.investmentType,
    );
  }
}
