// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealModel _$MealModelFromJson(Map<String, dynamic> json) => MealModel(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      mealType: json['mealType'] as String,
      foodName: json['foodName'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      imageUrl: json['imageUrl'] as String?,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$MealModelToJson(MealModel instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'mealType': instance.mealType,
      'foodName': instance.foodName,
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fats': instance.fats,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'imageUrl': instance.imageUrl,
      'loggedAt': instance.loggedAt.toIso8601String(),
      'notes': instance.notes,
    };

FoodItemModel _$FoodItemModelFromJson(Map<String, dynamic> json) => FoodItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      caloriesPer100g: (json['caloriesPer100g'] as num).toDouble(),
      proteinPer100g: (json['proteinPer100g'] as num).toDouble(),
      carbsPer100g: (json['carbsPer100g'] as num).toDouble(),
      fatsPer100g: (json['fatsPer100g'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$FoodItemModelToJson(FoodItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'caloriesPer100g': instance.caloriesPer100g,
      'proteinPer100g': instance.proteinPer100g,
      'carbsPer100g': instance.carbsPer100g,
      'fatsPer100g': instance.fatsPer100g,
      'imageUrl': instance.imageUrl,
      'tags': instance.tags,
    };

MealTemplateModel _$MealTemplateModelFromJson(Map<String, dynamic> json) =>
    MealTemplateModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      meals: (json['meals'] as List<dynamic>)
          .map((e) => MealModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MealTemplateModelToJson(MealTemplateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'meals': instance.meals,
      'totalCalories': instance.totalCalories,
      'createdAt': instance.createdAt.toIso8601String(),
    };
