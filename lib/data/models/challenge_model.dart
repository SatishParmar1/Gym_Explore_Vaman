import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'challenge_model.g.dart';

@JsonSerializable()
class ChallengeModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String type; // transformation, weekly, city, buddy, gym_clash
  final String goal;
  final DateTime startDate;
  final DateTime endDate;
  final int participantsCount;
  final String? prizeDescription;
  final String? badge;
  final bool isPremiumOnly;
  final String? city;
  final String? gymId;

  const ChallengeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.goal,
    required this.startDate,
    required this.endDate,
    required this.participantsCount,
    this.prizeDescription,
    this.badge,
    this.isPremiumOnly = false,
    this.city,
    this.gymId,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeModelToJson(this);

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        goal,
        startDate,
        endDate,
        participantsCount,
        prizeDescription,
        badge,
        isPremiumOnly,
        city,
        gymId,
      ];
}

@JsonSerializable()
class ChallengeParticipationModel extends Equatable {
  final String id;
  final String challengeId;
  final String userId;
  final DateTime joinedAt;
  final double progress;
  final int rank;
  final bool isCompleted;
  final DateTime? completedAt;

  const ChallengeParticipationModel({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.joinedAt,
    required this.progress,
    required this.rank,
    this.isCompleted = false,
    this.completedAt,
  });

  factory ChallengeParticipationModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeParticipationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeParticipationModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        challengeId,
        userId,
        joinedAt,
        progress,
        rank,
        isCompleted,
        completedAt,
      ];
}
