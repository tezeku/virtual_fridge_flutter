class Product {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double calories;
  final DateTime? expiryDate;
  final DateTime addedDate;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.calories,
    this.expiryDate,
    required this.addedDate,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    double? calories,
    DateTime? expiryDate,
    DateTime? addedDate,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      expiryDate: expiryDate ?? this.expiryDate,
      addedDate: addedDate ?? this.addedDate,
    );
  }

  bool get isExpired => expiryDate != null &&
      expiryDate!.isBefore(DateTime.now());

  bool get isExpiringSoon => expiryDate != null &&
      !isExpired &&
      expiryDate!.difference(DateTime.now()).inDays <= 3;
}