// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutModel _$WorkoutModelFromJson(Map<String, dynamic> json) => WorkoutModel(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      workoutName: json['workoutName'] as String,
      workoutType: json['workoutType'] as String?,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseLogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: (json['duration'] as num).toInt(),
      caloriesBurned: (json['caloriesBurned'] as num?)?.toInt(),
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$WorkoutModelToJson(WorkoutModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'workoutName': instance.workoutName,
      'workoutType': instance.workoutType,
      'exercises': instance.exercises,
      'duration': instance.duration,
      'caloriesBurned': instance.caloriesBurned,
      'loggedAt': instance.loggedAt.toIso8601String(),
      'notes': instance.notes,
    };

ExerciseLogModel _$ExerciseLogModelFromJson(Map<String, dynamic> json) =>
    ExerciseLogModel(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      bodyPart: json['bodyPart'] as String?,
      equipment: json['equipment'] as String?,
      sets: (json['sets'] as List<dynamic>)
          .map((e) => SetModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoUrl: json['videoUrl'] as String?,
    );

Map<String, dynamic> _$ExerciseLogModelToJson(ExerciseLogModel instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'bodyPart': instance.bodyPart,
      'equipment': instance.equipment,
      'sets': instance.sets,
      'videoUrl': instance.videoUrl,
    };

SetModel _$SetModelFromJson(Map<String, dynamic> json) => SetModel(
      setNumber: (json['setNumber'] as num).toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      reps: (json['reps'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$SetModelToJson(SetModel instance) => <String, dynamic>{
      'setNumber': instance.setNumber,
      'weight': instance.weight,
      'reps': instance.reps,
      'duration': instance.duration,
      'completed': instance.completed,
    };

ExerciseModel _$ExerciseModelFromJson(Map<String, dynamic> json) =>
    ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      bodyPart: json['bodyPart'] as String,
      equipment: json['equipment'] as String?,
      difficulty: json['difficulty'] as String,
      videoUrl: json['videoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      instructions: (json['instructions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ExerciseModelToJson(ExerciseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'bodyPart': instance.bodyPart,
      'equipment': instance.equipment,
      'difficulty': instance.difficulty,
      'videoUrl': instance.videoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'instructions': instance.instructions,
    };
