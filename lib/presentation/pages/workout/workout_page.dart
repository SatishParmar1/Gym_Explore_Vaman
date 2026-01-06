import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/workout/workout_bloc.dart';
import '../../blocs/workout/workout_event.dart';
import '../../blocs/workout/workout_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/workout_model.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutBloc>().add(WorkoutLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'WORKOUT',
          style: GoogleFonts.sairaExtraCondensed(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 1,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.history, color: AppColors.textSecondary),
              onPressed: () {
                // TODO: Show workout history
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<WorkoutBloc, WorkoutState>(
        builder: (context, state) {
          if (state is WorkoutLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'LOADING...',
                    style: GoogleFonts.sairaExtraCondensed(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is WorkoutError) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'ERROR',
                      style: GoogleFonts.sairaExtraCondensed(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: GoogleFonts.barlow(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<WorkoutBloc>().add(WorkoutLoadRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'RETRY',
                        style: GoogleFonts.sairaExtraCondensed(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is WorkoutLoaded) {
            return _buildLoadedView(state);
          }

          if (state is WorkoutInProgress) {
            return _buildWorkoutInProgressView(state);
          }

          if (state is WorkoutExerciseList) {
            return _buildExerciseListView(state);
          }

          return Center(
            child: Text(
              'Start your workout!',
              style: GoogleFonts.barlow(
                fontSize: 16,
                color: AppColors.textMuted,
              ),
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<WorkoutBloc, WorkoutState>(
        builder: (context, state) {
          if (state is WorkoutLoaded) {
            return Container(
              decoration: BoxDecoration(
                gradient: AppColors.fireGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  _showStartWorkoutDialog();
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  'START WORKOUT',
                  style: GoogleFonts.sairaExtraCondensed(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadedView(WorkoutLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Summary
          _buildTodaySummary(state),
          const SizedBox(height: 24),

          // Quick Start
          Text(
            'Quick Start',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildQuickStartOptions(),
          const SizedBox(height: 24),

          // Today's Workouts
          if (state.todayWorkouts.isNotEmpty) ...[
            Text(
              'Today\'s Workouts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...state.todayWorkouts.map((w) => _buildWorkoutCard(w)),
            const SizedBox(height: 24),
          ],

          // Recent Workouts
          Text(
            'Recent Workouts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (state.recentWorkouts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.fitness_center, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('No recent workouts'),
                    const SizedBox(height: 8),
                    const Text('Start your first workout today!'),
                  ],
                ),
              ),
            )
          else
            ...state.recentWorkouts.map((w) => _buildWorkoutCard(w)),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(WorkoutLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              Icons.timer,
              '${state.totalDuration}',
              'minutes',
              AppColors.primary,
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey[300],
            ),
            _buildSummaryItem(
              Icons.fitness_center,
              '${state.todayWorkouts.length}',
              'workouts',
              AppColors.secondary,
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey[300],
            ),
            _buildSummaryItem(
              Icons.local_fire_department,
              '${state.totalCaloriesBurned}',
              'calories',
              AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickStartOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickStartCard('Push Day', Icons.arrow_upward, AppColors.error),
          _buildQuickStartCard('Pull Day', Icons.arrow_downward, AppColors.primary),
          _buildQuickStartCard('Leg Day', Icons.directions_run, AppColors.secondary),
          _buildQuickStartCard('Full Body', Icons.accessibility_new, AppColors.warning),
          _buildQuickStartCard('Cardio', Icons.directions_bike, AppColors.info),
        ],
      ),
    );
  }

  Widget _buildQuickStartCard(String name, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          context.read<WorkoutBloc>().add(WorkoutStartSession(workoutName: name));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutModel workout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.fitness_center, color: AppColors.primary),
        ),
        title: Text(workout.workoutName),
        subtitle: Text(
          '${workout.exercises.length} exercises • ${workout.duration} min',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (workout.caloriesBurned != null)
              Text(
                '${workout.caloriesBurned} cal',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
              ),
            Text(
              _formatDate(workout.loggedAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        onTap: () {
          _showWorkoutDetails(workout);
        },
      ),
    );
  }

  Widget _buildWorkoutInProgressView(WorkoutInProgress state) {
    return Column(
      children: [
        // Timer and Controls
        Container(
          padding: const EdgeInsets.all(20),
          color: AppColors.primary,
          child: SafeArea(
            child: Column(
              children: [
                Text(
                  state.workoutName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  _formatDuration(state.elapsedSeconds),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        _showCancelWorkoutDialog();
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('Cancel', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<WorkoutBloc>().add(WorkoutFinishSession());
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Finish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Exercises List
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exercises (${state.completedExercises.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<WorkoutBloc>().add(const WorkoutSearchExercises());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Exercise'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (state.completedExercises.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.fitness_center, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text('No exercises added yet'),
                          const SizedBox(height: 8),
                          const Text('Tap "Add Exercise" to get started'),
                        ],
                      ),
                    ),
                  )
                else
                  ...state.completedExercises.map((exercise) => _buildExerciseInProgressCard(exercise)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseInProgressCard(ExerciseLogModel exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  exercise.exerciseName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (exercise.bodyPart != null)
                  Chip(
                    label: Text(exercise.bodyPart!),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Sets
            if (exercise.sets.isEmpty)
              const Text('No sets logged yet')
            else
              ...exercise.sets.map((set) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: set.completed ? AppColors.success : Colors.grey[300],
                          child: Text(
                            '${set.setNumber}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('${set.weight?.toStringAsFixed(1) ?? '-'} kg'),
                        const SizedBox(width: 8),
                        const Text('×'),
                        const SizedBox(width: 8),
                        Text('${set.reps ?? '-'} reps'),
                      ],
                    ),
                  )),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                _showAddSetDialog(exercise.exerciseId);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseListView(WorkoutExerciseList state) {
    final bodyParts = ['All', 'Chest', 'Back', 'Shoulders', 'Arms', 'Legs', 'Core'];

    return Column(
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: bodyParts.map((part) {
              final isSelected = state.filterBodyPart == part || (part == 'All' && state.filterBodyPart == null);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(part),
                  selected: isSelected,
                  onSelected: (selected) {
                    context.read<WorkoutBloc>().add(WorkoutSearchExercises(
                          bodyPart: part == 'All' ? null : part,
                        ));
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // Exercise list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.exercises.length,
            itemBuilder: (context, index) {
              final exercise = state.exercises[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getBodyPartColor(exercise.bodyPart).withOpacity(0.1),
                    child: Icon(
                      _getBodyPartIcon(exercise.bodyPart),
                      color: _getBodyPartColor(exercise.bodyPart),
                    ),
                  ),
                  title: Text(exercise.name),
                  subtitle: Text('${exercise.bodyPart} • ${exercise.equipment ?? 'Bodyweight'}'),
                  trailing: Chip(
                    label: Text(exercise.difficulty),
                    backgroundColor: _getDifficultyColor(exercise.difficulty).withOpacity(0.1),
                  ),
                  onTap: () {
                    context.read<WorkoutBloc>().add(WorkoutAddExercise(exercise: exercise));
                  },
                ),
              );
            },
          ),
        ),

        // Back button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.read<WorkoutBloc>().add(WorkoutLoadRequested());
              },
              child: const Text('Back to Workout'),
            ),
          ),
        ),
      ],
    );
  }

  void _showStartWorkoutDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Workout'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Workout Name',
            hintText: 'e.g., Push Day, Leg Day',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<WorkoutBloc>().add(WorkoutStartSession(workoutName: controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showAddSetDialog(String exerciseId) {
    double weight = 0;
    int reps = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Log Set'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                      ),
                      onChanged: (value) {
                        weight = double.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                      ),
                      onChanged: (value) {
                        reps = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final set = SetModel(
                  setNumber: 1, // Will be calculated by bloc
                  weight: weight,
                  reps: reps,
                  completed: true,
                );
                context.read<WorkoutBloc>().add(WorkoutLogSet(
                      exerciseId: exerciseId,
                      set: set,
                    ));
                Navigator.pop(context);
              },
              child: const Text('Log'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelWorkoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Workout?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Workout'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<WorkoutBloc>().add(WorkoutCancelSession());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel Workout'),
          ),
        ],
      ),
    );
  }

  void _showWorkoutDetails(WorkoutModel workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    workout.workoutName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${workout.duration} min • ${workout.exercises.length} exercises • ${workout.caloriesBurned ?? 0} cal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Divider(height: 32),
              ...workout.exercises.map((exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exerciseName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ...exercise.sets.map((set) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${set.setNumber}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('${set.weight?.toStringAsFixed(1) ?? 0} kg × ${set.reps ?? 0} reps'),
                                ],
                              ),
                            )),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getBodyPartColor(String bodyPart) {
    switch (bodyPart.toLowerCase()) {
      case 'chest':
        return AppColors.error;
      case 'back':
        return AppColors.primary;
      case 'shoulders':
        return AppColors.warning;
      case 'arms':
        return AppColors.info;
      case 'legs':
        return AppColors.secondary;
      case 'core':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getBodyPartIcon(String bodyPart) {
    switch (bodyPart.toLowerCase()) {
      case 'chest':
        return Icons.accessibility_new;
      case 'back':
        return Icons.airline_seat_flat;
      case 'shoulders':
        return Icons.sports_handball;
      case 'arms':
        return Icons.fitness_center;
      case 'legs':
        return Icons.directions_run;
      case 'core':
        return Icons.sports_gymnastics;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }
}
