// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChallengeModel _$ChallengeModelFromJson(Map<String, dynamic> json) =>
    ChallengeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      goal: json['goal'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      participantsCount: (json['participantsCount'] as num).toInt(),
      prizeDescription: json['prizeDescription'] as String?,
      badge: json['badge'] as String?,
      isPremiumOnly: json['isPremiumOnly'] as bool? ?? false,
      city: json['city'] as String?,
      gymId: json['gymId'] as String?,
    );

Map<String, dynamic> _$ChallengeModelToJson(ChallengeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'goal': instance.goal,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'participantsCount': instance.participantsCount,
      'prizeDescription': instance.prizeDescription,
      'badge': instance.badge,
      'isPremiumOnly': instance.isPremiumOnly,
      'city': instance.city,
      'gymId': instance.gymId,
    };

ChallengeParticipationModel _$ChallengeParticipationModelFromJson(
        Map<String, dynamic> json) =>
    ChallengeParticipationModel(
      id: json['id'] as String,
      challengeId: json['challengeId'] as String,
      userId: json['userId'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      progress: (json['progress'] as num).toDouble(),
      rank: (json['rank'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$ChallengeParticipationModelToJson(
        ChallengeParticipationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'challengeId': instance.challengeId,
      'userId': instance.userId,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'progress': instance.progress,
      'rank': instance.rank,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
    };
