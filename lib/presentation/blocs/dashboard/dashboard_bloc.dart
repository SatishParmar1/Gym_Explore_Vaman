import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../../data/models/gym_model.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onDashboardLoadRequested);
    on<DashboardRefreshRequested>(_onDashboardRefreshRequested);
    on<DashboardGymStatusRequested>(_onDashboardGymStatusRequested);
  }

  Future<void> _onDashboardLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      // TODO: Fetch data from repositories
      await Future.delayed(const Duration(seconds: 1));

      // Mock gym status
      final gymStatus = GymStatusModel(
        gymId: 'gym_123',
        currentOccupancy: 25,
        maxCapacity: 100,
        occupancyPercentage: 25.0,
        status: 'empty',
        lastUpdated: DateTime.now(),
      );

      // Mock daily progress
      final dailyProgress = {
        'calories': 1200.0,
        'target_calories': 2000.0,
        'water': 5.0,
        'target_water': 8.0,
        'protein': 80.0,
        'target_protein': 120.0,
      };

      emit(DashboardLoaded(
        gymStatus: gymStatus,
        dailyProgress: dailyProgress,
        currentStreak: 7,
        aiRecommendations: [
          'Great job maintaining your 7-day streak!',
          'Try adding 2.5kg to your bench press today',
          'You\'re 800 calories away from your goal',
        ],
      ));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onDashboardRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Refresh without showing loading state
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      
      try {
        // TODO: Fetch fresh data
        await Future.delayed(const Duration(milliseconds: 500));

        emit(currentState);
      } catch (e) {
        // Keep current state on error
      }
    }
  }

  Future<void> _onDashboardGymStatusRequested(
    DashboardGymStatusRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      
      try {
        // TODO: Fetch gym status from WebSocket/API
        await Future.delayed(const Duration(milliseconds: 300));

        final updatedGymStatus = GymStatusModel(
          gymId: event.gymId,
          currentOccupancy: 45,
          maxCapacity: 100,
          occupancyPercentage: 45.0,
          status: 'moderate',
          lastUpdated: DateTime.now(),
        );

        emit(DashboardLoaded(
          user: currentState.user,
          gymStatus: updatedGymStatus,
          dailyProgress: currentState.dailyProgress,
          currentStreak: currentState.currentStreak,
          aiRecommendations: currentState.aiRecommendations,
        ));
      } catch (e) {
        // Keep current state on error
      }
    }
  }
}
