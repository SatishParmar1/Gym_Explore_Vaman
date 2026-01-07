import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/workout_model.dart';
import '../config/supabase_config.dart';
import 'base_repository.dart';

/// Repository for workout-related operations.
/// 
/// Handles workout logging and management, including:
/// - Creating and updating workout logs
/// - Fetching workout history
/// - Exercise and set tracking
/// - Workout statistics
/// 
/// Example:
/// ```dart
/// final workoutRepo = WorkoutRepository();
/// 
/// // Log a workout
/// final workout = await workoutRepo.logWorkout(
///   workoutName: 'Morning Strength',
///   exercises: exercises,
///   duration: 45,
/// );
/// 
/// // Get workout history
/// final history = await workoutRepo.getWorkoutHistory(
///   startDate: DateTime.now().subtract(Duration(days: 7)),
/// );
/// ```
class WorkoutRepository extends BaseRepository {
  WorkoutRepository({
    super.database,
    super.storage,
    super.auth,
    super.realtime,
  });

  static const String _table = SupabaseTables.workouts;

  /// Get all workouts for current user
  Future<List<WorkoutModel>> getAllWorkouts({
    QueryOptions options = const QueryOptions(),
  }) async {
    requireAuth();

    return await database.fetchAll<WorkoutModel>(
      table: _table,
      fromJson: WorkoutModel.fromJson,
      column: 'user_id',
      equalTo: currentUserId,
      orderBy: options.orderBy ?? 'logged_at',
      ascending: options.ascending,
      limit: options.limit,
      offset: options.offset,
      filters: options.filters,
    );
  }

  /// Get paginated workout history
  Future<PaginatedResult<WorkoutModel>> getWorkoutHistory({
    int page = 1,
    int pageSize = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? workoutType,
  }) async {
    requireAuth();

    final filters = <String, dynamic>{};
    if (workoutType != null) filters['workout_type'] = workoutType;

    var workouts = await getAllWorkouts(
      options: QueryOptions.paginated(
        page: page,
        pageSize: pageSize + 1, // Fetch one extra to check if there's more
        orderBy: 'logged_at',
        ascending: false,
        filters: filters,
      ),
    );

    // Filter by date if needed (Supabase doesn't support date range in simple queries)
    if (startDate != null) {
      workouts = workouts.where((w) => w.loggedAt.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      workouts = workouts.where((w) => w.loggedAt.isBefore(endDate)).toList();
    }

    final hasMore = workouts.length > pageSize;
    if (hasMore) {
      workouts = workouts.take(pageSize).toList();
    }

    return PaginatedResult(
      items: workouts,
      page: page,
      pageSize: pageSize,
      hasMore: hasMore,
    );
  }

  /// Get a specific workout by ID
  Future<WorkoutModel?> getWorkoutById(String workoutId) async {
    return await database.fetchById<WorkoutModel>(
      table: _table,
      id: workoutId,
      fromJson: WorkoutModel.fromJson,
    );
  }

  /// Get workouts for a specific date
  Future<List<WorkoutModel>> getWorkoutsForDate(DateTime date) async {
    requireAuth();

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final allWorkouts = await getAllWorkouts(
      options: const QueryOptions(orderBy: 'logged_at', ascending: false),
    );

    return allWorkouts.where((w) {
      return w.loggedAt.isAfter(startOfDay) && w.loggedAt.isBefore(endOfDay);
    }).toList();
  }

  /// Get workouts for current week
  Future<List<WorkoutModel>> getWeeklyWorkouts() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final allWorkouts = await getAllWorkouts(
      options: const QueryOptions(orderBy: 'logged_at', ascending: false),
    );

    return allWorkouts.where((w) => w.loggedAt.isAfter(startOfDay)).toList();
  }

  /// Log a new workout
  Future<WorkoutModel> logWorkout({
    required String workoutName,
    String? workoutType,
    required List<ExerciseLogModel> exercises,
    required int duration,
    int? caloriesBurned,
    String? notes,
  }) async {
    requireAuth();

    final workoutData = {
      'user_id': currentUserId,
      'workout_name': workoutName,
      'workout_type': workoutType,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'duration': duration,
      'calories_burned': caloriesBurned,
      'logged_at': DateTime.now().toIso8601String(),
      'notes': notes,
    };

    return await database.insert<WorkoutModel>(
      table: _table,
      data: workoutData,
      fromJson: WorkoutModel.fromJson,
    );
  }

  /// Update an existing workout
  Future<WorkoutModel> updateWorkout({
    required String workoutId,
    String? workoutName,
    String? workoutType,
    List<ExerciseLogModel>? exercises,
    int? duration,
    int? caloriesBurned,
    String? notes,
  }) async {
    requireAuth();

    final updates = <String, dynamic>{};
    
    if (workoutName != null) updates['workout_name'] = workoutName;
    if (workoutType != null) updates['workout_type'] = workoutType;
    if (exercises != null) {
      updates['exercises'] = exercises.map((e) => e.toJson()).toList();
    }
    if (duration != null) updates['duration'] = duration;
    if (caloriesBurned != null) updates['calories_burned'] = caloriesBurned;
    if (notes != null) updates['notes'] = notes;

    return await database.update<WorkoutModel>(
      table: _table,
      id: workoutId,
      data: updates,
      fromJson: WorkoutModel.fromJson,
    );
  }

  /// Delete a workout
  Future<void> deleteWorkout(String workoutId) async {
    requireAuth();
    await database.delete(table: _table, id: workoutId);
  }

  /// Get workout count for current user
  Future<int> getWorkoutCount() async {
    requireAuth();

    return await database.count(
      table: _table,
      column: 'user_id',
      equalTo: currentUserId,
    );
  }

  /// Get total workout duration for a date range
  Future<int> getTotalDuration({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final workouts = await getAllWorkouts();
    
    var filtered = workouts;
    if (startDate != null) {
      filtered = filtered.where((w) => w.loggedAt.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      filtered = filtered.where((w) => w.loggedAt.isBefore(endDate)).toList();
    }

    return filtered.fold<int>(0, (sum, w) => sum + w.duration);
  }

  /// Get total calories burned for a date range
  Future<int> getTotalCaloriesBurned({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final workouts = await getAllWorkouts();
    
    var filtered = workouts;
    if (startDate != null) {
      filtered = filtered.where((w) => w.loggedAt.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      filtered = filtered.where((w) => w.loggedAt.isBefore(endDate)).toList();
    }

    return filtered.fold<int>(0, (sum, w) => sum + (w.caloriesBurned ?? 0));
  }

  /// Get workout statistics
  Future<WorkoutStats> getWorkoutStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    requireAuth();

    final workouts = await getAllWorkouts();
    
    var filtered = workouts;
    if (startDate != null) {
      filtered = filtered.where((w) => w.loggedAt.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      filtered = filtered.where((w) => w.loggedAt.isBefore(endDate)).toList();
    }

    return WorkoutStats(
      totalWorkouts: filtered.length,
      totalDuration: filtered.fold<int>(0, (sum, w) => sum + w.duration),
      totalCaloriesBurned: filtered.fold<int>(0, (sum, w) => sum + (w.caloriesBurned ?? 0)),
      totalExercises: filtered.fold<int>(0, (sum, w) => sum + w.exercises.length),
      workoutsByType: _groupByType(filtered),
    );
  }

  Map<String, int> _groupByType(List<WorkoutModel> workouts) {
    final grouped = <String, int>{};
    for (final workout in workouts) {
      final type = workout.workoutType ?? 'other';
      grouped[type] = (grouped[type] ?? 0) + 1;
    }
    return grouped;
  }

  /// Subscribe to real-time workout updates
  RealtimeChannel subscribeToWorkouts({
    void Function(WorkoutModel workout)? onInsert,
    void Function(WorkoutModel newWorkout, WorkoutModel? oldWorkout)? onUpdate,
    void Function(WorkoutModel workout)? onDelete,
  }) {
    requireAuth();

    return realtime.subscribeToUserData<WorkoutModel>(
      table: _table,
      userId: currentUserId!,
      fromJson: WorkoutModel.fromJson,
      onInsert: onInsert,
      onUpdate: onUpdate,
      onDelete: onDelete,
    );
  }
}

/// Workout statistics data class
class WorkoutStats {
  final int totalWorkouts;
  final int totalDuration;
  final int totalCaloriesBurned;
  final int totalExercises;
  final Map<String, int> workoutsByType;

  const WorkoutStats({
    required this.totalWorkouts,
    required this.totalDuration,
    required this.totalCaloriesBurned,
    required this.totalExercises,
    required this.workoutsByType,
  });

  /// Average workout duration in minutes
  double get averageDuration =>
      totalWorkouts > 0 ? totalDuration / totalWorkouts : 0;

  /// Average calories burned per workout
  double get averageCaloriesBurned =>
      totalWorkouts > 0 ? totalCaloriesBurned / totalWorkouts : 0;
}
