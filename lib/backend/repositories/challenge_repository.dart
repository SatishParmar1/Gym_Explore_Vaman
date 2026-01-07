import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/challenge_model.dart';
import '../config/supabase_config.dart';
import 'base_repository.dart';

/// Repository for challenge-related operations.
/// 
/// Handles fitness challenges including:
/// - Browsing available challenges
/// - Joining and leaving challenges
/// - Tracking challenge progress
/// - Challenge leaderboards
/// 
/// Example:
/// ```dart
/// final challengeRepo = ChallengeRepository();
/// 
/// // Get active challenges
/// final challenges = await challengeRepo.getActiveChallenges();
/// 
/// // Join a challenge
/// await challengeRepo.joinChallenge('challenge123');
/// 
/// // Update progress
/// await challengeRepo.updateProgress(
///   challengeId: 'challenge123',
///   progress: 50.0,
/// );
/// ```
class ChallengeRepository extends BaseRepository {
  ChallengeRepository({
    super.database,
    super.storage,
    super.auth,
    super.realtime,
  });

  static const String _table = SupabaseTables.challenges;
  static const String _participantsTable = SupabaseTables.challengeParticipants;

  /// Get all challenges
  Future<List<ChallengeModel>> getAllChallenges({
    QueryOptions options = const QueryOptions(),
  }) async {
    return await database.fetchAll<ChallengeModel>(
      table: _table,
      fromJson: ChallengeModel.fromJson,
      orderBy: options.orderBy ?? 'start_date',
      ascending: options.ascending,
      limit: options.limit,
      offset: options.offset,
      filters: options.filters,
    );
  }

  /// Get active challenges (currently running)
  Future<List<ChallengeModel>> getActiveChallenges() async {
    final allChallenges = await getAllChallenges();
    return allChallenges.where((c) => c.isActive).toList();
  }

  /// Get upcoming challenges
  Future<List<ChallengeModel>> getUpcomingChallenges() async {
    final now = DateTime.now();
    final allChallenges = await getAllChallenges();

    return allChallenges.where((c) => c.startDate.isAfter(now)).toList();
  }

  /// Get completed challenges
  Future<List<ChallengeModel>> getCompletedChallenges() async {
    final now = DateTime.now();
    final allChallenges = await getAllChallenges();

    return allChallenges.where((c) => c.endDate.isBefore(now)).toList();
  }

  /// Get a specific challenge by ID
  Future<ChallengeModel?> getChallengeById(String challengeId) async {
    return await database.fetchById<ChallengeModel>(
      table: _table,
      id: challengeId,
      fromJson: ChallengeModel.fromJson,
    );
  }

  /// Get challenges the current user has joined
  Future<List<ChallengeModel>> getUserChallenges() async {
    requireAuth();

    final participations = await database.fetchAll<Map<String, dynamic>>(
      table: _participantsTable,
      fromJson: (json) => json,
      column: 'user_id',
      equalTo: currentUserId,
    );

    final challengeIds = participations
        .map((p) => p['challenge_id'] as String)
        .toList();

    if (challengeIds.isEmpty) return [];

    final allChallenges = await getAllChallenges();
    return allChallenges
        .where((c) => challengeIds.contains(c.id))
        .toList();
  }

  /// Check if user has joined a challenge
  Future<bool> hasJoinedChallenge(String challengeId) async {
    requireAuth();

    final participation = await database.fetchOne(
      table: _participantsTable,
      fromJson: (json) => json,
      column: 'user_id',
      value: currentUserId,
    );

    return participation != null &&
        participation['challenge_id'] == challengeId;
  }

  /// Join a challenge
  Future<void> joinChallenge(String challengeId) async {
    requireAuth();

    // Check if already joined
    if (await hasJoinedChallenge(challengeId)) {
      return;
    }

    await database.insert(
      table: _participantsTable,
      data: {
        'challenge_id': challengeId,
        'user_id': currentUserId,
        'joined_at': DateTime.now().toIso8601String(),
        'progress': 0.0,
        'is_completed': false,
        'rank': 0,
      },
      fromJson: (json) => json,
    );

    // Update participant count
    final challenge = await getChallengeById(challengeId);
    if (challenge != null) {
      await database.update(
        table: _table,
        id: challengeId,
        data: {'participants_count': challenge.participantsCount + 1},
        fromJson: ChallengeModel.fromJson,
      );
    }
  }

  /// Leave a challenge
  Future<void> leaveChallenge(String challengeId) async {
    requireAuth();

    await database.deleteWhere(
      table: _participantsTable,
      column: 'user_id',
      value: currentUserId,
    );

    // Update participant count
    final challenge = await getChallengeById(challengeId);
    if (challenge != null && challenge.participantsCount > 0) {
      await database.update(
        table: _table,
        id: challengeId,
        data: {'participants_count': challenge.participantsCount - 1},
        fromJson: ChallengeModel.fromJson,
      );
    }
  }

  /// Update user's progress in a challenge
  Future<void> updateProgress({
    required String challengeId,
    required double progress,
  }) async {
    requireAuth();

    final isCompleted = progress >= 100;

    await database.updateWhere(
      table: _participantsTable,
      data: {
        'progress': progress,
        'is_completed': isCompleted,
      },
      column: 'user_id',
      value: currentUserId,
      fromJson: (json) => json,
    );
  }

  /// Get user's progress in a challenge
  Future<ChallengeProgress?> getUserProgress(String challengeId) async {
    requireAuth();

    final participation = await database.fetchOne(
      table: _participantsTable,
      fromJson: (json) => json,
      column: 'user_id',
      value: currentUserId,
    );

    if (participation == null ||
        participation['challenge_id'] != challengeId) {
      return null;
    }

    return ChallengeProgress(
      challengeId: challengeId,
      userId: currentUserId!,
      progress: (participation['progress'] as num).toDouble(),
      isCompleted: participation['is_completed'] as bool,
      joinedAt: DateTime.parse(participation['joined_at']),
      rank: participation['rank'] as int? ?? 0,
    );
  }

  /// Get challenge leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard(String challengeId) async {
    final participants = await database.fetchAll<Map<String, dynamic>>(
      table: _participantsTable,
      fromJson: (json) => json,
      column: 'challenge_id',
      equalTo: challengeId,
      orderBy: 'progress',
      ascending: false,
    );

    return participants.asMap().entries.map((entry) {
      final p = entry.value;
      return LeaderboardEntry(
        rank: entry.key + 1,
        userId: p['user_id'] as String,
        progress: (p['progress'] as num).toDouble(),
        isCompleted: p['is_completed'] as bool,
      );
    }).toList();
  }

  /// Get challenges by type
  Future<List<ChallengeModel>> getChallengesByType(String type) async {
    return await database.fetchAll<ChallengeModel>(
      table: _table,
      fromJson: ChallengeModel.fromJson,
      column: 'type',
      equalTo: type,
      orderBy: 'start_date',
    );
  }

  /// Get challenges by city
  Future<List<ChallengeModel>> getChallengesByCity(String city) async {
    return await database.fetchAll<ChallengeModel>(
      table: _table,
      fromJson: ChallengeModel.fromJson,
      column: 'city',
      equalTo: city,
      orderBy: 'start_date',
    );
  }

  /// Subscribe to challenge updates
  RealtimeChannel subscribeToChallenge({
    required String challengeId,
    void Function(ChallengeModel challenge)? onUpdate,
  }) {
    return realtime.subscribeToRecord<ChallengeModel>(
      table: _table,
      recordId: challengeId,
      fromJson: ChallengeModel.fromJson,
      onUpdate: onUpdate,
    );
  }

  /// Subscribe to leaderboard updates
  RealtimeChannel subscribeToLeaderboard({
    required String challengeId,
    void Function()? onUpdate,
  }) {
    return realtime.subscribeToTable<Map<String, dynamic>>(
      table: _participantsTable,
      fromJson: (json) => json,
      filterColumn: 'challenge_id',
      filterValue: challengeId,
      onAny: (_, __, ___) => onUpdate?.call(),
    );
  }
}

/// User's progress in a challenge
class ChallengeProgress {
  final String challengeId;
  final String userId;
  final double progress;
  final bool isCompleted;
  final DateTime joinedAt;
  final int rank;

  const ChallengeProgress({
    required this.challengeId,
    required this.userId,
    required this.progress,
    required this.isCompleted,
    required this.joinedAt,
    required this.rank,
  });
}

/// Leaderboard entry
class LeaderboardEntry {
  final int rank;
  final String userId;
  final double progress;
  final bool isCompleted;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.progress,
    required this.isCompleted,
  });
}
