import 'package:equatable/equatable.dart';
import '../../../data/models/workout_model.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

class WorkoutLoadRequested extends WorkoutEvent {}

class WorkoutStartSession extends WorkoutEvent {
  final String workoutName;

  const WorkoutStartSession({required this.workoutName});

  @override
  List<Object?> get props => [workoutName];
}

class WorkoutAddExercise extends WorkoutEvent {
  final ExerciseModel exercise;

  const WorkoutAddExercise({required this.exercise});

  @override
  List<Object?> get props => [exercise];
}

class WorkoutLogSet extends WorkoutEvent {
  final String exerciseId;
  final SetModel set;

  const WorkoutLogSet({
    required this.exerciseId,
    required this.set,
  });

  @override
  List<Object?> get props => [exerciseId, set];
}

class WorkoutFinishSession extends WorkoutEvent {}

class WorkoutCancelSession extends WorkoutEvent {}

class WorkoutSearchExercises extends WorkoutEvent {
  final String? query;
  final String? bodyPart;
  final String? equipment;

  const WorkoutSearchExercises({
    this.query,
    this.bodyPart,
    this.equipment,
  });

  @override
  List<Object?> get props => [query, bodyPart, equipment];
}

class WorkoutLogQuick extends WorkoutEvent {
  final WorkoutModel workout;

  const WorkoutLogQuick({required this.workout});

  @override
  List<Object?> get props => [workout];
}
