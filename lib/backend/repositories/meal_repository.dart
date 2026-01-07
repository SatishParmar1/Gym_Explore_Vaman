import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/meal_model.dart';
import '../config/supabase_config.dart';
import '../services/supabase_storage_service.dart';
import 'base_repository.dart';

/// Repository for meal and nutrition-related operations.
/// 
/// Handles meal logging and nutrition tracking, including:
/// - Logging meals and food items
/// - Calculating daily nutrition totals
/// - Meal history and statistics
/// 
/// Example:
/// ```dart
/// final mealRepo = MealRepository();
/// 
/// // Log a meal
/// final meal = await mealRepo.logMeal(
///   mealType: 'lunch',
///   foodName: 'Chicken Salad',
///   calories: 350,
/// );
/// 
/// // Get daily nutrition summary
/// final nutrition = await mealRepo.getDailyNutrition(DateTime.now());
/// ```
class MealRepository extends BaseRepository {
  MealRepository({
    super.database,
    super.storage,
    super.auth,
    super.realtime,
  });

  static const String _table = SupabaseTables.meals;
  static const String _mealImagesBucket = SupabaseBuckets.mealImages;

  /// Get all meals for current user
  Future<List<MealModel>> getAllMeals({
    QueryOptions options = const QueryOptions(),
  }) async {
    requireAuth();

    return await database.fetchAll<MealModel>(
      table: _table,
      fromJson: MealModel.fromJson,
      column: 'user_id',
      equalTo: currentUserId,
      orderBy: options.orderBy ?? 'logged_at',
      ascending: options.ascending,
      limit: options.limit,
      offset: options.offset,
      filters: options.filters,
    );
  }

  /// Get paginated meal history
  Future<PaginatedResult<MealModel>> getMealHistory({
    int page = 1,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? mealType,
  }) async {
    requireAuth();

    final filters = <String, dynamic>{};
    if (mealType != null) filters['meal_type'] = mealType;

    var meals = await getAllMeals(
      options: QueryOptions.paginated(
        page: page,
        pageSize: pageSize + 1,
        orderBy: 'logged_at',
        ascending: false,
        filters: filters,
      ),
    );

    if (startDate != null) {
      meals = meals.where((m) => m.loggedAt.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      meals = meals.where((m) => m.loggedAt.isBefore(endDate)).toList();
    }

    final hasMore = meals.length > pageSize;
    if (hasMore) {
      meals = meals.take(pageSize).toList();
    }

    return PaginatedResult(
      items: meals,
      page: page,
      pageSize: pageSize,
      hasMore: hasMore,
    );
  }

  /// Get a specific meal by ID
  Future<MealModel?> getMealById(String mealId) async {
    return await database.fetchById<MealModel>(
      table: _table,
      id: mealId,
      fromJson: MealModel.fromJson,
    );
  }

  /// Get meals for a specific date
  Future<List<MealModel>> getMealsForDate(DateTime date) async {
    requireAuth();

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final allMeals = await getAllMeals(
      options: const QueryOptions(orderBy: 'logged_at', ascending: true),
    );

    return allMeals.where((m) {
      return m.loggedAt.isAfter(startOfDay) && m.loggedAt.isBefore(endOfDay);
    }).toList();
  }

  /// Log a new meal
  Future<MealModel> logMeal({
    required String mealType,
    required String foodName,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    required double quantity,
    required String unit,
    String? notes,
    File? imageFile,
  }) async {
    requireAuth();

    String? imageUrl;
    if (imageFile != null) {
      final path = storage.generateFilePath(
        folder: 'meals',
        userId: currentUserId!,
        originalFileName: 'meal_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      imageUrl = await storage.uploadFile(
        bucket: _mealImagesBucket,
        path: path,
        file: imageFile,
        allowedExtensions: SupabaseStorageService.imageExtensions,
      );
    }

    final mealData = {
      'user_id': currentUserId,
      'meal_type': mealType,
      'food_name': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'quantity': quantity,
      'unit': unit,
      'logged_at': DateTime.now().toIso8601String(),
      'notes': notes,
      'image_url': imageUrl,
    };

    return await database.insert<MealModel>(
      table: _table,
      data: mealData,
      fromJson: MealModel.fromJson,
    );
  }

  /// Update an existing meal
  Future<MealModel> updateMeal({
    required String mealId,
    String? mealType,
    String? foodName,
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
    double? quantity,
    String? unit,
    String? notes,
  }) async {
    requireAuth();

    final updates = <String, dynamic>{};
    
    if (mealType != null) updates['meal_type'] = mealType;
    if (foodName != null) updates['food_name'] = foodName;
    if (calories != null) updates['calories'] = calories;
    if (protein != null) updates['protein'] = protein;
    if (carbs != null) updates['carbs'] = carbs;
    if (fats != null) updates['fats'] = fats;
    if (quantity != null) updates['quantity'] = quantity;
    if (unit != null) updates['unit'] = unit;
    if (notes != null) updates['notes'] = notes;

    return await database.update<MealModel>(
      table: _table,
      id: mealId,
      data: updates,
      fromJson: MealModel.fromJson,
    );
  }

  /// Delete a meal
  Future<void> deleteMeal(String mealId) async {
    requireAuth();

    final meal = await getMealById(mealId);
    if (meal?.imageUrl != null) {
      try {
        // Delete associated image
        await storage.deleteFile(
          bucket: _mealImagesBucket,
          path: meal!.imageUrl!,
        );
      } catch (_) {}
    }

    await database.delete(table: _table, id: mealId);
  }

  /// Get daily nutrition summary
  Future<DailyNutrition> getDailyNutrition(DateTime date) async {
    final meals = await getMealsForDate(date);

    return DailyNutrition(
      date: date,
      meals: meals,
      totalCalories: meals.fold<double>(0, (sum, m) => sum + m.calories),
      totalProtein: meals.fold<double>(0, (sum, m) => sum + m.protein),
      totalCarbs: meals.fold<double>(0, (sum, m) => sum + m.carbs),
      totalFat: meals.fold<double>(0, (sum, m) => sum + m.fats),
    );
  }

  /// Get weekly nutrition summary
  Future<List<DailyNutrition>> getWeeklyNutrition() async {
    final now = DateTime.now();
    final results = <DailyNutrition>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final nutrition = await getDailyNutrition(date);
      results.add(nutrition);
    }

    return results;
  }

  /// Subscribe to real-time meal updates
  RealtimeChannel subscribeToMeals({
    void Function(MealModel meal)? onInsert,
    void Function(MealModel newMeal, MealModel? oldMeal)? onUpdate,
    void Function(MealModel meal)? onDelete,
  }) {
    requireAuth();

    return realtime.subscribeToUserData<MealModel>(
      table: _table,
      userId: currentUserId!,
      fromJson: MealModel.fromJson,
      onInsert: onInsert,
      onUpdate: onUpdate,
      onDelete: onDelete,
    );
  }
}

/// Daily nutrition summary
class DailyNutrition {
  final DateTime date;
  final List<MealModel> meals;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const DailyNutrition({
    required this.date,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  /// Number of meals logged
  int get mealCount => meals.length;

  /// Check if calories goal is met (assuming 2000 cal default)
  bool hasMetCalorieGoal(double goal) => totalCalories >= goal;
}
