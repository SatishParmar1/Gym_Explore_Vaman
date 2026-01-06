import 'package:equatable/equatable.dart';
import '../../../data/models/meal_model.dart';

abstract class DietState extends Equatable {
  const DietState();

  @override
  List<Object?> get props => [];
}

class DietInitial extends DietState {}

class DietLoading extends DietState {}

class DietLoaded extends DietState {
  final List<MealModel> todayMeals;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final double targetCalories;
  final List<FoodItemModel> recentFoods;
  final List<MealTemplateModel> mealTemplates;

  const DietLoaded({
    required this.todayMeals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.targetCalories,
    required this.recentFoods,
    required this.mealTemplates,
  });

  double get caloriesRemaining => targetCalories - totalCalories;
  double get caloriesPercentage => (totalCalories / targetCalories).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
        todayMeals,
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFats,
        targetCalories,
        recentFoods,
        mealTemplates,
      ];
}

class DietFoodSearchResult extends DietState {
  final List<FoodItemModel> results;
  final String query;

  const DietFoodSearchResult({
    required this.results,
    required this.query,
  });

  @override
  List<Object?> get props => [results, query];
}

class DietMealLogging extends DietState {
  final FoodItemModel? selectedFood;
  final String mealType;

  const DietMealLogging({
    this.selectedFood,
    required this.mealType,
  });

  @override
  List<Object?> get props => [selectedFood, mealType];
}

class DietError extends DietState {
  final String message;

  const DietError({required this.message});

  @override
  List<Object?> get props => [message];
}
