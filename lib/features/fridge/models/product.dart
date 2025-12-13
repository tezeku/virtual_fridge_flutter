import 'package:intl/intl.dart';

import '../../../shared/constants.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double calories;
  final DateTime? expiryDate;
  final DateTime addedDate;
  final String? notes;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.calories,
    this.expiryDate,
    required this.addedDate,
    this.notes,
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
    String? notes,
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
      notes: notes ?? this.notes,
    );
  }

  bool get isExpired => expiryDate != null &&
      expiryDate!.isBefore(DateTime.now());

  bool get isExpiringSoon => expiryDate != null &&
      !isExpired &&
      expiryDate!.difference(DateTime.now()).inDays <= AppConstants.expiryWarningDays;

  String get status {
    if (isExpired) return 'Просрочено';
    if (isExpiringSoon) return 'Скоро истекает';
    return 'Свежий';
  }

  String get formattedExpiryDate {
    if (expiryDate == null) return 'Нет срока годности';
    return DateFormat('dd.MM.yyyy').format(expiryDate!);
  }

  String get formattedAddedDate {
    return DateFormat('dd.MM.yyyy').format(addedDate);
  }

  double get totalCalories => (quantity / 100) * calories;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'expiryDate': expiryDate?.toIso8601String(),
      'addedDate': addedDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'],
      calories: (json['calories'] as num).toDouble(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      addedDate: DateTime.parse(json['addedDate']),
      notes: json['notes'],
    );
  }
}