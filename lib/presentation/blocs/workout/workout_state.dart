import 'package:equatable/equatable.dart';
import '../../../data/models/workout_model.dart';

abstract class WorkoutState extends Equatable {
  const WorkoutState();

  @override
  List<Object?> get props => [];
}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutLoaded extends WorkoutState {
  final List<WorkoutModel> todayWorkouts;
  final List<WorkoutModel> recentWorkouts;
  final List<ExerciseModel> exercises;
  final int totalDuration;
  final int totalCaloriesBurned;

  const WorkoutLoaded({
    required this.todayWorkouts,
    required this.recentWorkouts,
    required this.exercises,
    required this.totalDuration,
    required this.totalCaloriesBurned,
  });

  @override
  List<Object?> get props => [
        todayWorkouts,
        recentWorkouts,
        exercises,
        totalDuration,
        totalCaloriesBurned,
      ];
}

class WorkoutInProgress extends WorkoutState {
  final String workoutName;
  final List<ExerciseLogModel> completedExercises;
  final ExerciseModel? currentExercise;
  final DateTime startTime;
  final int elapsedSeconds;

  const WorkoutInProgress({
    required this.workoutName,
    required this.completedExercises,
    this.currentExercise,
    required this.startTime,
    required this.elapsedSeconds,
  });

  @override
  List<Object?> get props => [
        workoutName,
        completedExercises,
        currentExercise,
        startTime,
        elapsedSeconds,
      ];
}

class WorkoutExerciseList extends WorkoutState {
  final List<ExerciseModel> exercises;
  final String? filterBodyPart;
  final String? filterEquipment;

  const WorkoutExerciseList({
    required this.exercises,
    this.filterBodyPart,
    this.filterEquipment,
  });

  @override
  List<Object?> get props => [exercises, filterBodyPart, filterEquipment];
}

class WorkoutError extends WorkoutState {
  final String message;

  const WorkoutError({required this.message});

  @override
  List<Object?> get props => [message];
}
