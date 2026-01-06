import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meal_model.g.dart';

@JsonSerializable()
class MealModel extends Equatable {
  final String? id;
  final String userId;
  final String mealType; // breakfast, lunch, dinner, snack
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double quantity;
  final String unit; // grams, ml, piece, bowl
  final String? imageUrl;
  final DateTime loggedAt;
  final String? notes;

  const MealModel({
    this.id,
    required this.userId,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.quantity,
    required this.unit,
    this.imageUrl,
    required this.loggedAt,
    this.notes,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) =>
      _$MealModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        mealType,
        foodName,
        calories,
        protein,
        carbs,
        fats,
        quantity,
        unit,
        imageUrl,
        loggedAt,
        notes,
      ];
}

@JsonSerializable()
class FoodItemModel extends Equatable {
  final String id;
  final String name;
  final String category;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatsPer100g;
  final String? imageUrl;
  final List<String>? tags;

  const FoodItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
    this.imageUrl,
    this.tags,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) =>
      _$FoodItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$FoodItemModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        caloriesPer100g,
        proteinPer100g,
        carbsPer100g,
        fatsPer100g,
        imageUrl,
        tags,
      ];
}

@JsonSerializable()
class MealTemplateModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final List<MealModel> meals;
  final double totalCalories;
  final DateTime createdAt;

  const MealTemplateModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.meals,
    required this.totalCalories,
    required this.createdAt,
  });

  factory MealTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$MealTemplateModelFromJson(json);

  Map<String, dynamic> toJson() => _$MealTemplateModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        meals,
        totalCalories,
        createdAt,
      ];
}
