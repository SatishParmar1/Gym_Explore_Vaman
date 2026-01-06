import 'package:flutter_bloc/flutter_bloc.dart';
import 'diet_event.dart';
import 'diet_state.dart';
import '../../../data/models/meal_model.dart';

class DietBloc extends Bloc<DietEvent, DietState> {
  final List<MealModel> _todayMeals = [];
  final List<FoodItemModel> _recentFoods = [];
  final List<MealTemplateModel> _mealTemplates = [];
  double _targetCalories = 2000.0;

  DietBloc() : super(DietInitial()) {
    on<DietLoadRequested>(_onDietLoadRequested);
    on<DietSearchFood>(_onDietSearchFood);
    on<DietLogMeal>(_onDietLogMeal);
    on<DietDeleteMeal>(_onDietDeleteMeal);
    on<DietVoiceInput>(_onDietVoiceInput);
    on<DietSaveTemplate>(_onDietSaveTemplate);
    on<DietLogFromTemplate>(_onDietLogFromTemplate);
  }

  Future<void> _onDietLoadRequested(
    DietLoadRequested event,
    Emitter<DietState> emit,
  ) async {
    emit(DietLoading());

    try {
      // TODO: Fetch from repository
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      final mockMeals = [
        MealModel(
          id: 'meal_1',
          userId: 'user_1',
          mealType: 'breakfast',
          foodName: 'Poha',
          calories: 250,
          protein: 8,
          carbs: 45,
          fats: 5,
          quantity: 1,
          unit: 'bowl',
          loggedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        MealModel(
          id: 'meal_2',
          userId: 'user_1',
          mealType: 'snack',
          foodName: 'Chai',
          calories: 80,
          protein: 2,
          carbs: 10,
          fats: 3,
          quantity: 1,
          unit: 'cup',
          loggedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

      _todayMeals.clear();
      _todayMeals.addAll(mockMeals);

      // Mock recent foods
      _recentFoods.addAll([
        const FoodItemModel(
          id: 'food_1',
          name: 'Poha',
          category: 'Breakfast',
          caloriesPer100g: 200,
          proteinPer100g: 6,
          carbsPer100g: 35,
          fatsPer100g: 4,
        ),
        const FoodItemModel(
          id: 'food_2',
          name: 'Dal Rice',
          category: 'Lunch',
          caloriesPer100g: 180,
          proteinPer100g: 8,
          carbsPer100g: 30,
          fatsPer100g: 3,
        ),
        const FoodItemModel(
          id: 'food_3',
          name: 'Roti',
          category: 'Dinner',
          caloriesPer100g: 120,
          proteinPer100g: 3,
          carbsPer100g: 25,
          fatsPer100g: 1,
        ),
      ]);

      emit(_buildLoadedState());
    } catch (e) {
      emit(DietError(message: e.toString()));
    }
  }

  Future<void> _onDietSearchFood(
    DietSearchFood event,
    Emitter<DietState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(_buildLoadedState());
      return;
    }

    try {
      // TODO: Search from food database
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock search results - Indian food database
      final mockResults = _getIndianFoodDatabase()
          .where((food) => food.name.toLowerCase().contains(event.query.toLowerCase()))
          .toList();

      emit(DietFoodSearchResult(results: mockResults, query: event.query));
    } catch (e) {
      emit(DietError(message: e.toString()));
    }
  }

  Future<void> _onDietLogMeal(
    DietLogMeal event,
    Emitter<DietState> emit,
  ) async {
    emit(DietLoading());

    try {
      // TODO: Save to repository
      await Future.delayed(const Duration(milliseconds: 300));

      _todayMeals.add(event.meal);

      emit(_buildLoadedState());
    } catch (e) {
      emit(DietError(message: e.toString()));
    }
  }

  Future<void> _onDietDeleteMeal(
    DietDeleteMeal event,
    Emitter<DietState> emit,
  ) async {
    try {
      _todayMeals.removeWhere((meal) => meal.id == event.mealId);
      emit(_buildLoadedState());
    } catch (e) {
      emit(DietError(message: e.toString()));
    }
  }

  Future<void> _onDietVoiceInput(
    DietVoiceInput event,
    Emitter<DietState> emit,
  ) async {
    emit(DietLoading());

    try {
      // TODO: Parse voice input with NLP
      // Example: "I had 2 rotis and dal for lunch"
      await Future.delayed(const Duration(milliseconds: 500));

      // For now, search for the food
      final results = _getIndianFoodDatabase()
          .where((food) => food.name.toLowerCase().contains(event.voiceText.toLowerCase()))
          .toList();

      if (results.isNotEmpty) {
        emit(DietFoodSearchResult(results: results, query: event.voiceText));
      } else {
        emit(_buildLoadedState());
      }
    } catch (e) {
      emit(DietError(message: e.toString()));
    }
  }

  Future<void> _onDietSaveTemplate(
    DietSaveTemplate event,
    Emitter<DietState> emit,
  ) async {
    try {
      final template = MealTemplateModel(
        id: 'template_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_1',
        name: event.name,
        meals: event.meals,
        totalCalories: event.meals.fold(0, (sum, meal) => sum + meal.calories.toInt()).toDouble(),
        createdAt: DateTime.now(),
      );

      _mealTemplates.add(template);
      emit(_buildLoadedState());
    } catch (e) {
      emit(DietError(message: e.toString()));
    }
  }

  Future<void> _onDietLogFromTemplate(
    DietLogFromTemplate event,
    Emitter<DietState> emit,
  ) async {
    emit(DietLoading());

    try {
      for (final meal in event.template.meals) {
        _todayMeals.add(MealModel(
          id: 'meal_${DateTime.now().millisecondsSinceEpoch}',
          userId: meal.userId,
          mealType: meal.mealType,
          foodName: meal.foodName,
          calories: meal.calories,
          protein: meal.protein,
          carbs: meal.carbs,
          fats: meal.fats,
          quantity: meal.quantity,
          unit: meal.unit,
          loggedAt: DateTime.now(),
        ));
      }

      emit(_buildLoadedState());
    } catch (e) {
      emit(DietError(message: e.toString()));
    }
  }

  DietLoaded _buildLoadedState() {
    final totalCalories = _todayMeals.fold<double>(0, (sum, meal) => sum + meal.calories);
    final totalProtein = _todayMeals.fold<double>(0, (sum, meal) => sum + meal.protein);
    final totalCarbs = _todayMeals.fold<double>(0, (sum, meal) => sum + meal.carbs);
    final totalFats = _todayMeals.fold<double>(0, (sum, meal) => sum + meal.fats);

    return DietLoaded(
      todayMeals: List.from(_todayMeals),
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
      targetCalories: _targetCalories,
      recentFoods: List.from(_recentFoods),
      mealTemplates: List.from(_mealTemplates),
    );
  }

  List<FoodItemModel> _getIndianFoodDatabase() {
    return const [
      // Breakfast Items
      FoodItemModel(id: '1', name: 'Poha', category: 'Breakfast', caloriesPer100g: 200, proteinPer100g: 6, carbsPer100g: 35, fatsPer100g: 4),
      FoodItemModel(id: '2', name: 'Upma', category: 'Breakfast', caloriesPer100g: 185, proteinPer100g: 5, carbsPer100g: 32, fatsPer100g: 4),
      FoodItemModel(id: '3', name: 'Idli (2 pieces)', category: 'Breakfast', caloriesPer100g: 150, proteinPer100g: 4, carbsPer100g: 30, fatsPer100g: 1),
      FoodItemModel(id: '4', name: 'Dosa', category: 'Breakfast', caloriesPer100g: 168, proteinPer100g: 4, carbsPer100g: 28, fatsPer100g: 5),
      FoodItemModel(id: '5', name: 'Paratha', category: 'Breakfast', caloriesPer100g: 300, proteinPer100g: 6, carbsPer100g: 40, fatsPer100g: 12),
      FoodItemModel(id: '6', name: 'Aloo Paratha', category: 'Breakfast', caloriesPer100g: 320, proteinPer100g: 7, carbsPer100g: 45, fatsPer100g: 13),
      
      // Main Course
      FoodItemModel(id: '7', name: 'Dal (1 bowl)', category: 'Main Course', caloriesPer100g: 120, proteinPer100g: 8, carbsPer100g: 20, fatsPer100g: 1),
      FoodItemModel(id: '8', name: 'Rice (1 cup)', category: 'Main Course', caloriesPer100g: 130, proteinPer100g: 3, carbsPer100g: 28, fatsPer100g: 0),
      FoodItemModel(id: '9', name: 'Roti', category: 'Main Course', caloriesPer100g: 120, proteinPer100g: 3, carbsPer100g: 25, fatsPer100g: 1),
      FoodItemModel(id: '10', name: 'Rajma (1 bowl)', category: 'Main Course', caloriesPer100g: 140, proteinPer100g: 9, carbsPer100g: 23, fatsPer100g: 1),
      FoodItemModel(id: '11', name: 'Chole (1 bowl)', category: 'Main Course', caloriesPer100g: 160, proteinPer100g: 8, carbsPer100g: 27, fatsPer100g: 3),
      FoodItemModel(id: '12', name: 'Paneer Curry (1 bowl)', category: 'Main Course', caloriesPer100g: 265, proteinPer100g: 14, carbsPer100g: 12, fatsPer100g: 18),
      FoodItemModel(id: '13', name: 'Chicken Curry (1 bowl)', category: 'Main Course', caloriesPer100g: 240, proteinPer100g: 25, carbsPer100g: 10, fatsPer100g: 12),
      
      // Snacks
      FoodItemModel(id: '14', name: 'Samosa (1 piece)', category: 'Snacks', caloriesPer100g: 262, proteinPer100g: 4, carbsPer100g: 25, fatsPer100g: 16),
      FoodItemModel(id: '15', name: 'Pakora (5 pieces)', category: 'Snacks', caloriesPer100g: 300, proteinPer100g: 5, carbsPer100g: 20, fatsPer100g: 22),
      FoodItemModel(id: '16', name: 'Vada Pav', category: 'Snacks', caloriesPer100g: 290, proteinPer100g: 6, carbsPer100g: 35, fatsPer100g: 14),
      FoodItemModel(id: '17', name: 'Pav Bhaji', category: 'Snacks', caloriesPer100g: 340, proteinPer100g: 8, carbsPer100g: 45, fatsPer100g: 15),
      
      // Beverages
      FoodItemModel(id: '18', name: 'Chai (1 cup)', category: 'Beverages', caloriesPer100g: 80, proteinPer100g: 2, carbsPer100g: 10, fatsPer100g: 3),
      FoodItemModel(id: '19', name: 'Lassi (1 glass)', category: 'Beverages', caloriesPer100g: 150, proteinPer100g: 5, carbsPer100g: 20, fatsPer100g: 5),
      FoodItemModel(id: '20', name: 'Buttermilk (1 glass)', category: 'Beverages', caloriesPer100g: 40, proteinPer100g: 2, carbsPer100g: 5, fatsPer100g: 1),
      
      // Sweets
      FoodItemModel(id: '21', name: 'Gulab Jamun (1 piece)', category: 'Sweets', caloriesPer100g: 150, proteinPer100g: 2, carbsPer100g: 25, fatsPer100g: 5),
      FoodItemModel(id: '22', name: 'Jalebi (2 pieces)', category: 'Sweets', caloriesPer100g: 350, proteinPer100g: 2, carbsPer100g: 60, fatsPer100g: 12),
      FoodItemModel(id: '23', name: 'Kheer (1 bowl)', category: 'Sweets', caloriesPer100g: 180, proteinPer100g: 4, carbsPer100g: 28, fatsPer100g: 6),
      
      // Protein Sources
      FoodItemModel(id: '24', name: 'Egg (1 boiled)', category: 'Protein', caloriesPer100g: 78, proteinPer100g: 6, carbsPer100g: 0, fatsPer100g: 5),
      FoodItemModel(id: '25', name: 'Chicken Breast (100g)', category: 'Protein', caloriesPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatsPer100g: 4),
      FoodItemModel(id: '26', name: 'Paneer (100g)', category: 'Protein', caloriesPer100g: 265, proteinPer100g: 18, carbsPer100g: 2, fatsPer100g: 20),
      FoodItemModel(id: '27', name: 'Soya Chunks (100g)', category: 'Protein', caloriesPer100g: 345, proteinPer100g: 52, carbsPer100g: 30, fatsPer100g: 1),
    ];
  }
}
