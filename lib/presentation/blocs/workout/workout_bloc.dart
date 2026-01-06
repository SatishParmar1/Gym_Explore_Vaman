import 'package:flutter_bloc/flutter_bloc.dart';
import 'workout_event.dart';
import 'workout_state.dart';
import '../../../data/models/workout_model.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final List<WorkoutModel> _todayWorkouts = [];
  final List<WorkoutModel> _recentWorkouts = [];
  final List<ExerciseLogModel> _currentExercises = [];
  String? _currentWorkoutName;
  DateTime? _workoutStartTime;

  WorkoutBloc() : super(WorkoutInitial()) {
    on<WorkoutLoadRequested>(_onWorkoutLoadRequested);
    on<WorkoutStartSession>(_onWorkoutStartSession);
    on<WorkoutAddExercise>(_onWorkoutAddExercise);
    on<WorkoutLogSet>(_onWorkoutLogSet);
    on<WorkoutFinishSession>(_onWorkoutFinishSession);
    on<WorkoutCancelSession>(_onWorkoutCancelSession);
    on<WorkoutSearchExercises>(_onWorkoutSearchExercises);
    on<WorkoutLogQuick>(_onWorkoutLogQuick);
  }

  Future<void> _onWorkoutLoadRequested(
    WorkoutLoadRequested event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock recent workouts
      _recentWorkouts.addAll([
        WorkoutModel(
          id: 'workout_1',
          userId: 'user_1',
          workoutName: 'Push Day',
          workoutType: 'strength',
          exercises: const [
            ExerciseLogModel(
              exerciseId: '1',
              exerciseName: 'Bench Press',
              bodyPart: 'Chest',
              sets: [
                SetModel(setNumber: 1, weight: 60, reps: 12, completed: true),
                SetModel(setNumber: 2, weight: 65, reps: 10, completed: true),
                SetModel(setNumber: 3, weight: 70, reps: 8, completed: true),
              ],
            ),
          ],
          duration: 45,
          caloriesBurned: 320,
          loggedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);

      final totalDuration = _todayWorkouts.fold<int>(0, (sum, w) => sum + w.duration);
      final totalCalories = _todayWorkouts.fold<int>(0, (sum, w) => sum + (w.caloriesBurned ?? 0));

      emit(WorkoutLoaded(
        todayWorkouts: List.from(_todayWorkouts),
        recentWorkouts: List.from(_recentWorkouts),
        exercises: _getExerciseDatabase(),
        totalDuration: totalDuration,
        totalCaloriesBurned: totalCalories,
      ));
    } catch (e) {
      emit(WorkoutError(message: e.toString()));
    }
  }

  Future<void> _onWorkoutStartSession(
    WorkoutStartSession event,
    Emitter<WorkoutState> emit,
  ) async {
    _currentWorkoutName = event.workoutName;
    _workoutStartTime = DateTime.now();
    _currentExercises.clear();

    emit(WorkoutInProgress(
      workoutName: event.workoutName,
      completedExercises: const [],
      startTime: _workoutStartTime!,
      elapsedSeconds: 0,
    ));
  }

  Future<void> _onWorkoutAddExercise(
    WorkoutAddExercise event,
    Emitter<WorkoutState> emit,
  ) async {
    if (state is WorkoutInProgress) {
      final currentState = state as WorkoutInProgress;

      final exerciseLog = ExerciseLogModel(
        exerciseId: event.exercise.id,
        exerciseName: event.exercise.name,
        bodyPart: event.exercise.bodyPart,
        equipment: event.exercise.equipment,
        sets: const [],
      );

      _currentExercises.add(exerciseLog);

      emit(WorkoutInProgress(
        workoutName: currentState.workoutName,
        completedExercises: List.from(_currentExercises),
        currentExercise: event.exercise,
        startTime: currentState.startTime,
        elapsedSeconds: DateTime.now().difference(currentState.startTime).inSeconds,
      ));
    }
  }

  Future<void> _onWorkoutLogSet(
    WorkoutLogSet event,
    Emitter<WorkoutState> emit,
  ) async {
    if (state is WorkoutInProgress) {
      final currentState = state as WorkoutInProgress;

      final exerciseIndex = _currentExercises.indexWhere(
        (e) => e.exerciseId == event.exerciseId,
      );

      if (exerciseIndex != -1) {
        final exercise = _currentExercises[exerciseIndex];
        final updatedSets = [...exercise.sets, event.set];
        
        _currentExercises[exerciseIndex] = ExerciseLogModel(
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          bodyPart: exercise.bodyPart,
          equipment: exercise.equipment,
          sets: updatedSets,
        );

        emit(WorkoutInProgress(
          workoutName: currentState.workoutName,
          completedExercises: List.from(_currentExercises),
          currentExercise: currentState.currentExercise,
          startTime: currentState.startTime,
          elapsedSeconds: DateTime.now().difference(currentState.startTime).inSeconds,
        ));
      }
    }
  }

  Future<void> _onWorkoutFinishSession(
    WorkoutFinishSession event,
    Emitter<WorkoutState> emit,
  ) async {
    if (state is WorkoutInProgress) {
      final currentState = state as WorkoutInProgress;

      final workout = WorkoutModel(
        id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_1',
        workoutName: currentState.workoutName,
        workoutType: 'strength',
        exercises: List.from(_currentExercises),
        duration: currentState.elapsedSeconds ~/ 60,
        caloriesBurned: _estimateCaloriesBurned(_currentExercises, currentState.elapsedSeconds),
        loggedAt: DateTime.now(),
      );

      _todayWorkouts.add(workout);
      _currentExercises.clear();
      _currentWorkoutName = null;
      _workoutStartTime = null;

      final totalDuration = _todayWorkouts.fold<int>(0, (sum, w) => sum + w.duration);
      final totalCalories = _todayWorkouts.fold<int>(0, (sum, w) => sum + (w.caloriesBurned ?? 0));

      emit(WorkoutLoaded(
        todayWorkouts: List.from(_todayWorkouts),
        recentWorkouts: List.from(_recentWorkouts),
        exercises: _getExerciseDatabase(),
        totalDuration: totalDuration,
        totalCaloriesBurned: totalCalories,
      ));
    }
  }

  Future<void> _onWorkoutCancelSession(
    WorkoutCancelSession event,
    Emitter<WorkoutState> emit,
  ) async {
    _currentExercises.clear();
    _currentWorkoutName = null;
    _workoutStartTime = null;

    add(WorkoutLoadRequested());
  }

  Future<void> _onWorkoutSearchExercises(
    WorkoutSearchExercises event,
    Emitter<WorkoutState> emit,
  ) async {
    var exercises = _getExerciseDatabase();

    if (event.query != null && event.query!.isNotEmpty) {
      exercises = exercises
          .where((e) => e.name.toLowerCase().contains(event.query!.toLowerCase()))
          .toList();
    }

    if (event.bodyPart != null) {
      exercises = exercises
          .where((e) => e.bodyPart.toLowerCase() == event.bodyPart!.toLowerCase())
          .toList();
    }

    if (event.equipment != null) {
      exercises = exercises
          .where((e) => e.equipment?.toLowerCase() == event.equipment!.toLowerCase())
          .toList();
    }

    emit(WorkoutExerciseList(
      exercises: exercises,
      filterBodyPart: event.bodyPart,
      filterEquipment: event.equipment,
    ));
  }

  Future<void> _onWorkoutLogQuick(
    WorkoutLogQuick event,
    Emitter<WorkoutState> emit,
  ) async {
    _todayWorkouts.add(event.workout);

    final totalDuration = _todayWorkouts.fold<int>(0, (sum, w) => sum + w.duration);
    final totalCalories = _todayWorkouts.fold<int>(0, (sum, w) => sum + (w.caloriesBurned ?? 0));

    emit(WorkoutLoaded(
      todayWorkouts: List.from(_todayWorkouts),
      recentWorkouts: List.from(_recentWorkouts),
      exercises: _getExerciseDatabase(),
      totalDuration: totalDuration,
      totalCaloriesBurned: totalCalories,
    ));
  }

  int _estimateCaloriesBurned(List<ExerciseLogModel> exercises, int seconds) {
    // Rough estimate: 5-8 calories per minute for strength training
    final minutes = seconds / 60;
    final baseCalories = minutes * 6;
    final exerciseBonus = exercises.length * 15;
    return (baseCalories + exerciseBonus).round();
  }

  List<ExerciseModel> _getExerciseDatabase() {
    return const [
      // Chest
      ExerciseModel(
        id: '1',
        name: 'Bench Press',
        bodyPart: 'Chest',
        equipment: 'Barbell',
        difficulty: 'intermediate',
        instructions: ['Lie on bench', 'Grip bar wider than shoulders', 'Lower to chest', 'Press up'],
      ),
      ExerciseModel(
        id: '2',
        name: 'Incline Dumbbell Press',
        bodyPart: 'Chest',
        equipment: 'Dumbbells',
        difficulty: 'intermediate',
        instructions: ['Set bench to 30-45 degrees', 'Press dumbbells up', 'Lower with control'],
      ),
      ExerciseModel(
        id: '3',
        name: 'Push-ups',
        bodyPart: 'Chest',
        equipment: 'Bodyweight',
        difficulty: 'beginner',
        instructions: ['Hands shoulder-width apart', 'Lower chest to floor', 'Push back up'],
      ),
      ExerciseModel(
        id: '4',
        name: 'Cable Flyes',
        bodyPart: 'Chest',
        equipment: 'Cable',
        difficulty: 'intermediate',
      ),

      // Back
      ExerciseModel(
        id: '5',
        name: 'Deadlift',
        bodyPart: 'Back',
        equipment: 'Barbell',
        difficulty: 'advanced',
        instructions: ['Stand with feet hip-width', 'Grip bar outside legs', 'Keep back straight', 'Lift with legs and back'],
      ),
      ExerciseModel(
        id: '6',
        name: 'Lat Pulldown',
        bodyPart: 'Back',
        equipment: 'Cable',
        difficulty: 'beginner',
      ),
      ExerciseModel(
        id: '7',
        name: 'Bent Over Row',
        bodyPart: 'Back',
        equipment: 'Barbell',
        difficulty: 'intermediate',
      ),
      ExerciseModel(
        id: '8',
        name: 'Pull-ups',
        bodyPart: 'Back',
        equipment: 'Bodyweight',
        difficulty: 'intermediate',
      ),

      // Shoulders
      ExerciseModel(
        id: '9',
        name: 'Overhead Press',
        bodyPart: 'Shoulders',
        equipment: 'Barbell',
        difficulty: 'intermediate',
      ),
      ExerciseModel(
        id: '10',
        name: 'Lateral Raises',
        bodyPart: 'Shoulders',
        equipment: 'Dumbbells',
        difficulty: 'beginner',
      ),
      ExerciseModel(
        id: '11',
        name: 'Face Pulls',
        bodyPart: 'Shoulders',
        equipment: 'Cable',
        difficulty: 'beginner',
      ),

      // Arms
      ExerciseModel(
        id: '12',
        name: 'Bicep Curls',
        bodyPart: 'Arms',
        equipment: 'Dumbbells',
        difficulty: 'beginner',
      ),
      ExerciseModel(
        id: '13',
        name: 'Tricep Pushdowns',
        bodyPart: 'Arms',
        equipment: 'Cable',
        difficulty: 'beginner',
      ),
      ExerciseModel(
        id: '14',
        name: 'Hammer Curls',
        bodyPart: 'Arms',
        equipment: 'Dumbbells',
        difficulty: 'beginner',
      ),

      // Legs
      ExerciseModel(
        id: '15',
        name: 'Squats',
        bodyPart: 'Legs',
        equipment: 'Barbell',
        difficulty: 'intermediate',
        instructions: ['Bar on upper back', 'Feet shoulder-width', 'Squat to parallel', 'Drive through heels'],
      ),
      ExerciseModel(
        id: '16',
        name: 'Leg Press',
        bodyPart: 'Legs',
        equipment: 'Machine',
        difficulty: 'beginner',
      ),
      ExerciseModel(
        id: '17',
        name: 'Romanian Deadlift',
        bodyPart: 'Legs',
        equipment: 'Barbell',
        difficulty: 'intermediate',
      ),
      ExerciseModel(
        id: '18',
        name: 'Leg Curls',
        bodyPart: 'Legs',
        equipment: 'Machine',
        difficulty: 'beginner',
      ),
      ExerciseModel(
        id: '19',
        name: 'Calf Raises',
        bodyPart: 'Legs',
        equipment: 'Machine',
        difficulty: 'beginner',
      ),

      // Core
      ExerciseModel(
        id: '20',
        name: 'Plank',
        bodyPart: 'Core',
        equipment: 'Bodyweight',
        difficulty: 'beginner',
      ),
      ExerciseModel(
        id: '21',
        name: 'Cable Crunches',
        bodyPart: 'Core',
        equipment: 'Cable',
        difficulty: 'intermediate',
      ),
      ExerciseModel(
        id: '22',
        name: 'Hanging Leg Raises',
        bodyPart: 'Core',
        equipment: 'Bodyweight',
        difficulty: 'intermediate',
      ),
    ];
  }
}
