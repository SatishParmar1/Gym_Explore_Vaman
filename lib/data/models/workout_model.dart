import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout_model.g.dart';

@JsonSerializable()
class WorkoutModel extends Equatable {
  final String? id;
  final String userId;
  final String workoutName;
  final String? workoutType; // strength, cardio, flexibility
  final List<ExerciseLogModel> exercises;
  final int duration; // in minutes
  final int? caloriesBurned;
  final DateTime loggedAt;
  final String? notes;

  const WorkoutModel({
    this.id,
    required this.userId,
    required this.workoutName,
    this.workoutType,
    required this.exercises,
    required this.duration,
    this.caloriesBurned,
    required this.loggedAt,
    this.notes,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        workoutName,
        workoutType,
        exercises,
        duration,
        caloriesBurned,
        loggedAt,
        notes,
      ];
}

@JsonSerializable()
class ExerciseLogModel extends Equatable {
  final String exerciseId;
  final String exerciseName;
  final String? bodyPart;
  final String? equipment;
  final List<SetModel> sets;
  final String? videoUrl;

  const ExerciseLogModel({
    required this.exerciseId,
    required this.exerciseName,
    this.bodyPart,
    this.equipment,
    required this.sets,
    this.videoUrl,
  });

  factory ExerciseLogModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseLogModelToJson(this);

  @override
  List<Object?> get props => [
        exerciseId,
        exerciseName,
        bodyPart,
        equipment,
        sets,
        videoUrl,
      ];
}

@JsonSerializable()
class SetModel extends Equatable {
  final int setNumber;
  final double? weight; // in kg
  final int? reps;
  final int? duration; // in seconds for time-based exercises
  final bool completed;

  const SetModel({
    required this.setNumber,
    this.weight,
    this.reps,
    this.duration,
    this.completed = false,
  });

  factory SetModel.fromJson(Map<String, dynamic> json) =>
      _$SetModelFromJson(json);

  Map<String, dynamic> toJson() => _$SetModelToJson(this);

  @override
  List<Object?> get props => [
        setNumber,
        weight,
        reps,
        duration,
        completed,
      ];
}

@JsonSerializable()
class ExerciseModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String bodyPart;
  final String? equipment;
  final String difficulty; // beginner, intermediate, advanced
  final String? videoUrl;
  final String? thumbnailUrl;
  final List<String>? instructions;

  const ExerciseModel({
    required this.id,
    required this.name,
    this.description,
    required this.bodyPart,
    this.equipment,
    required this.difficulty,
    this.videoUrl,
    this.thumbnailUrl,
    this.instructions,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        bodyPart,
        equipment,
        difficulty,
        videoUrl,
        thumbnailUrl,
        instructions,
      ];
}
