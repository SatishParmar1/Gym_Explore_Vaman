import 'package:equatable/equatable.dart';
import '../../../data/models/gym_model.dart';
import '../../../data/models/user_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final UserModel? user;
  final GymStatusModel? gymStatus;
  final Map<String, double> dailyProgress;
  final int currentStreak;
  final List<String> aiRecommendations;

  const DashboardLoaded({
    this.user,
    this.gymStatus,
    required this.dailyProgress,
    required this.currentStreak,
    required this.aiRecommendations,
  });

  @override
  List<Object?> get props => [
        user,
        gymStatus,
        dailyProgress,
        currentStreak,
        aiRecommendations,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
