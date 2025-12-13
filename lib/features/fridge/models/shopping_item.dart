class ShoppingItem {
  final String id;
  final String name;
  final String category;
  final double neededQuantity;
  final String unit;
  final bool isBought;
  final DateTime addedDate;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.neededQuantity,
    required this.unit,
    required this.isBought,
    required this.addedDate,
  });

  ShoppingItem copyWith({
    String? name,
    String? category,
    double? neededQuantity,
    String? unit,
    bool? isBought,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      neededQuantity: neededQuantity ?? this.neededQuantity,
      unit: unit ?? this.unit,
      isBought: isBought ?? this.isBought,
      addedDate: addedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'neededQuantity': neededQuantity,
      'unit': unit,
      'isBought': isBought,
      'addedDate': addedDate.toIso8601String(),
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      neededQuantity: (json['neededQuantity'] as num).toDouble(),
      unit: json['unit'] as String,
      isBought: json['isBought'] as bool? ?? false,
      addedDate: DateTime.parse(json['addedDate'] as String),
    );
  }
}
